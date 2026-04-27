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
    unused_declarations_analyzer: bool,
    simplify_name_analyzer: bool,
}

fn get_custom_args(settings_object: Option<&Map<String, Value>>) -> Vec<String> {
    if let Some(args) = settings_object
        .and_then(|s| s.get("fsac_custom_args"))
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
    final_args.extend_from_slice(custom_args);
    final_args.push("--adaptive-lsp-server-enabled".to_string());
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
        _language_server_id: &zed::LanguageServerId,
        _worktree: &zed::Worktree,
    ) -> zed::Result<Option<zed::serde_json::Value>> {
        let initialization_options = FsAutocompleteInitOptions {
            automatic_workspace_init: true,
            analyze_unused_declarations: true,
            unused_declarations_analyzer: true,
            simplify_name_analyzer: true,
        };

        Ok(Some(serde_json::json!(initialization_options)))
    }
}

zed::register_extension!(FsharpExtension);
