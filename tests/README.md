# Language query fixtures

These fixtures exercise the grammar pinned in `extension.toml`. They are
parser/query examples, not a compilable F# project.

With that grammar checked out at `grammars/fsharp` and Tree-sitter CLI installed,
run from `grammars/fsharp/fsharp`:

```sh
tree-sitter parse ../../../tests/fixtures/textobjects.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/textobjects.fs
tree-sitter parse ../../../tests/fixtures/textobjects_namespace.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/textobjects_namespace.fs
tree-sitter parse ../../../tests/fixtures/brackets.fs
tree-sitter query ../../../languages/fsharp/brackets.scm ../../../tests/fixtures/brackets.fs
tree-sitter query ../../../languages/fsharp/textobjects.scm ../../../tests/fixtures/brackets.fs
tree-sitter parse ../../../tests/fixtures/explicit_delimiters.fs
tree-sitter query ../../../languages/fsharp/brackets.scm ../../../tests/fixtures/explicit_delimiters.fs
```

Expected behavior:

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
value bound to a lambda has no parameterized declaration and is excluded.
Mutually recursive `let rec ... and ...` and `type ... and ...` declarations
share outer grammar nodes, so their around objects cover the entire group.
