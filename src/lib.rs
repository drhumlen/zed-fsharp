use std::path::PathBuf;
use zed_extension_api::{
    self as zed,
    serde_json::{self, Map, Value},
    settings::LspSettings,
    LanguageServerInstallationStatus,
};

mod fsac;

struct FsharpExtension {}

#[derive(serde::Serialize)]
#[serde(rename_all = "PascalCase")]
struct FsAutocompleteInitOptions {
    automatic_workspace_init: bool,
    analyze_unused_declarations: bool,
    simplify_name_analyzer: bool,
    tooltip_show_documentation_link: bool,
    unused_opens_analyzer: bool,
    unused_declarations_analyzer: bool,
    add_private_access_modifier: bool,
    external_autocomplete: bool,
    interface_stub_generation: bool,
    abstract_class_stub_generation: bool,
    union_case_stub_generation: bool,
    record_stub_generation: bool,
}

fn get_custom_args(settings_object: Option<&Map<String, Value>>) -> Vec<String> {
    if let Some(args) = settings_object
        .and_then(|s| {
            s.get("fsac_custom_arguments")
                .or_else(|| s.get("fsac_custom_args"))
        })
        .and_then(|v| v.as_array())
    {
        args.iter()
            .filter_map(|v| v.as_str().map(String::from))
            .collect()
    } else {
        Vec::new()
    }
}

fn require_dotnet(
    language_server_id: &zed::LanguageServerId,
    worktree: &zed::Worktree,
) -> zed::Result<String> {
    match worktree.which("dotnet") {
        Some(p) => Ok(p),
        None => {
            let error_msg = "dotnet executable not found in PATH".to_string();
            zed::set_language_server_installation_status(
                language_server_id,
                &LanguageServerInstallationStatus::Failed(error_msg.clone()),
            );
            Err(error_msg)
        }
    }
}

fn get_final_args(fsac_path: PathBuf, custom_args: &[String]) -> Vec<String> {
    let mut final_args = vec![fsac_path.to_string_lossy().to_string()];
    for arg in custom_args
        .iter()
        .cloned()
        .chain(std::iter::once("--adaptive-lsp-server-enabled".to_string()))
    {
        if !final_args.contains(&arg) {
            final_args.push(arg);
        }
    }
    final_args
}

impl zed::Extension for FsharpExtension {
    fn new() -> Self
    where
        Self: Sized,
    {
        Self {}
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<zed::Command> {
        let settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)?.settings;
        let settings_object = settings.as_ref().and_then(|v| v.as_object());
        let custom_args = get_custom_args(settings_object);

        // Explicit .dll path via settings — always run via dotnet
        if let Some(custom_path) = settings_object
            .and_then(|s| s.get("fsac_custom_path"))
            .and_then(|v| v.as_str())
        {
            let dotnet_path = require_dotnet(language_server_id, worktree)?;
            let final_args = get_final_args(PathBuf::from(custom_path), &custom_args);
            return Ok(zed::Command {
                command: dotnet_path,
                args: final_args,
                env: worktree.shell_env(),
            });
        }

        // fsautocomplete binary found in shell PATH — run directly
        if let Some(fsac_path) = worktree.which("fsautocomplete") {
            let mut args = custom_args.clone();
            args.push("--adaptive-lsp-server-enabled".to_string());
            return Ok(zed::Command {
                command: fsac_path,
                args,
                env: worktree.shell_env(),
            });
        }

        // Fall back to downloading via NuGet and running via dotnet
        let dotnet_path = require_dotnet(language_server_id, worktree)?;
        let acquisition = match fsac::acquire_fsac(language_server_id, worktree, &custom_args) {
            Ok(a) => a,
            Err(e) => {
                zed::set_language_server_installation_status(
                    language_server_id,
                    &LanguageServerInstallationStatus::Failed(e.clone()),
                );
                return Err(e);
            }
        };
        let final_args = get_final_args(acquisition.fsac_path, &custom_args);
        Ok(zed::Command {
            command: dotnet_path,
            args: final_args,
            env: acquisition.env,
        })
    }

    fn language_server_initialization_options(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> zed::Result<Option<zed::serde_json::Value>> {
        let initialization_options = FsAutocompleteInitOptions {
            automatic_workspace_init: true,
            analyze_unused_declarations: true,
            simplify_name_analyzer: true,
            // Zed does not support info panel so documentation links are not shown
            tooltip_show_documentation_link: false,
            unused_opens_analyzer: true,
            unused_declarations_analyzer: true,
            add_private_access_modifier: true,
            external_autocomplete: false,
            interface_stub_generation: true,
            abstract_class_stub_generation: true,
            union_case_stub_generation: true,
            record_stub_generation: true,
        };

        // Defaults deep-merged with the user's lsp.fsautocomplete.initialization_options —
        // user keys win per key, so setting one option doesn't wipe the defaults.
        let mut options = serde_json::json!(initialization_options);
        if let Some(user_options) = LspSettings::for_worktree(language_server_id.as_ref(), worktree)
            .ok()
            .and_then(|settings| settings.initialization_options)
        {
            merge(&mut options, user_options);
        }

        Ok(Some(options))
    }
}

/// Recursively overlay `overlay` onto `base`; objects merge per key,
/// everything else is replaced by the overlay value.
fn merge(base: &mut Value, overlay: Value) {
    match (base, overlay) {
        (Value::Object(base_map), Value::Object(overlay_map)) => {
            for (key, value) in overlay_map {
                merge(base_map.entry(key).or_insert(Value::Null), value);
            }
        }
        (base_slot, overlay) => *base_slot = overlay,
    }
}

zed::register_extension!(FsharpExtension);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn initialization_overrides_preserve_other_defaults() {
        let mut defaults = serde_json::json!({
            "SimplifyNameAnalyzer": true,
            "RecordStubGeneration": true,
            "fsac": { "cachedTypeCheckCount": 200, "other": true }
        });
        merge(&mut defaults, serde_json::json!({
            "SimplifyNameAnalyzer": false,
            "fsac": { "cachedTypeCheckCount": 50 }
        }));
        assert_eq!(defaults, serde_json::json!({
            "SimplifyNameAnalyzer": false,
            "RecordStubGeneration": true,
            "fsac": { "cachedTypeCheckCount": 50, "other": true }
        }));
    }

    #[test]
    fn custom_arguments_use_documented_setting() {
        let settings = serde_json::json!({
            "fsac_custom_arguments": ["--verbose", "value with spaces"],
            "fsac_custom_args": ["--legacy"]
        });
        assert_eq!(
            get_custom_args(settings.as_object()),
            vec!["--verbose", "value with spaces"]
        );
    }

    #[test]
    fn custom_arguments_preserve_legacy_setting() {
        let settings = serde_json::json!({ "fsac_custom_args": ["--verbose"] });
        assert_eq!(get_custom_args(settings.as_object()), vec!["--verbose"]);
    }

    #[test]
    fn empty_documented_arguments_override_legacy_setting() {
        let settings = serde_json::json!({
            "fsac_custom_arguments": [],
            "fsac_custom_args": ["--legacy"]
        });
        assert!(get_custom_args(settings.as_object()).is_empty());
        assert!(get_custom_args(None).is_empty());
    }
}
