# Language query fixtures

These fixtures exercise the grammar pinned in `extension.toml`. They are
parser/query examples, not a compilable F# project.

`computation_expressions.fs` covers applicative bindings: `let!` and both `and!`
tokens must capture as `@keyword.function`. The same text in the comment and
string must not receive that keyword capture.

With that grammar checked out at `grammars/fsharp` and Tree-sitter CLI installed,
run from `grammars/fsharp/fsharp`:

```sh
tree-sitter parse ../../../tests/fixtures/indentation.fs
tree-sitter query ../../../languages/fsharp/indents.scm ../../../tests/fixtures/indentation.fs
tree-sitter parse ../../../tests/fixtures/computation_expressions.fs
tree-sitter query ../../../languages/fsharp/highlights.scm ../../../tests/fixtures/computation_expressions.fs
tree-sitter parse ../../../tests/fixtures/interpolated_strings.fs
tree-sitter query ../../../languages/fsharp/highlights.scm ../../../tests/fixtures/interpolated_strings.fs
tree-sitter parse ../../../tests/fixtures/function_calls.fs
tree-sitter query ../../../languages/fsharp/highlights.scm ../../../tests/fixtures/function_calls.fs
tree-sitter parse ../../../tests/fixtures/textobjects.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/textobjects.fs
tree-sitter parse ../../../tests/fixtures/textobjects_namespace.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/textobjects_namespace.fs
tree-sitter parse ../../../tests/fixtures/brackets.fs
tree-sitter query ../../../languages/fsharp/brackets.scm ../../../tests/fixtures/brackets.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/brackets.fs
tree-sitter parse ../../../tests/fixtures/explicit_delimiters.fs
tree-sitter query ../../../languages/fsharp/brackets.scm ../../../tests/fixtures/explicit_delimiters.fs
tree-sitter parse ../../../tests/fixtures/editing.fs
tree-sitter query ../../../languages/fsharp/brackets.scm ../../../tests/fixtures/editing.fs
tree-sitter parse ../../../tests/fixtures/lambdas.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/lambdas.fs
```

Expected behavior:

- Interpolated string contents remain strings, interpolation braces are special
  punctuation, and expressions inside the braces use ordinary F# highlighting.
- Function calls on either side of an infix operator are highlighted, including
  `max 1 2 + min 3 4` and qualified calls such as `Math.Max x + Math.Min y`.
- Parameterized lets, including local functions, have function-around and body
  captures. `answer` has neither. Local function-around excludes the following
  expression that uses the local function.
- Instance/static members have function-around captures including their
  keywords; function-inside captures their implementation expressions.
- Types, nested modules, file modules, and namespaces have class-around captures.
- Record interiors exclude braces; union/enum interiors include their cases.
- Class and nested-module interiors span all body declarations. Multiple
  class-inside captures must belong to the same query match: Zed merges only
  captures from one match. Constructor parameters are excluded.
- Both comment forms have comment-around captures.
- Each bracket match has exactly one open and one close capture, including
  arrays, anonymous records, explicit type bodies, and both loop forms.

Reload the development extension in Zed and use `vaf`/`vif`, `vac`/`vic`,
`[m`/`]m`, `[[`/`]]`, and `%` on the fixtures to check editor behavior.

`brackets.fs` uses ordinary indentation-based F#: records and record updates,
pipelines, pattern matching, implicit interfaces, classes, loops, and an async
computation expression. On `calculateTotal`, `printPrices`, `countDown`, and
`loadTotal`, `vaf` selects the full binding and `vif` selects its body. `vic`
inside `Calculator` or `Reports` spans the body declarations. `%` matches the
actual delimiters in records, collections, parentheses, and `async { ... }`.
Indentation-based loops have no closing token for `%`; function text objects
select the surrounding function and its body. Optional `begin/end`, explicit
type bodies, and `do/done` are covered separately in `explicit_delimiters.fs`.

Limitations: file modules and namespaces currently have around captures only.
Implemented properties are intentionally included as function targets. A
value bound to a lambda has no parameterized declaration: its anonymous function
is captured, but the surrounding `let name =` is excluded.
Mutually recursive `let rec ... and ...` and `type ... and ...` declarations
share outer grammar nodes, so their around objects cover the entire group.

## Editing checks

In a scratch F# buffer, type `[|`, `{|`, and `[<`: extending an auto-closed
`[]` or `{}` should not insert a second closing delimiter. Complete the compound
closing delimiter manually. Use Zed's block-comment command on a selection and
check that it wraps with `(* ... *)`. C-style `/* ... */` is no longer configured.
Typing `'T` or `value'` should not insert another apostrophe. Character literals
still work, but their closing apostrophe is typed manually.
Use `%` on both attribute sets in `editing.fs` to check `[< ... >]` matching.

The documented `fsac_custom_arguments` setting now takes precedence over the
legacy `fsac_custom_args` spelling, including when explicitly set to `[]`.
Argument-setting behavior is covered by `cargo test`.

## Anonymous function objects

In `lambdas.fs`, put the cursor on `value + 1`: `vaf` selects
`fun value -> value + 1`, and `vif` selects `value + 1`. In the nested filter
callback, `vif` selects only `value > 0`. Inside a `function` expression, `vaf`
includes `function` and all cases, while `vif` selects just the cases. Surrounding
call parentheses and the `let describe =` binding are excluded. The plain
`answer` binding must not receive a function capture.
