;; ----------------------------------------------------------------------------
;; Literals and comments

[
  (line_comment)
  (block_comment)
] @comment

((line_comment) @comment.documentation
 (#match? @comment.documentation "^///"))

(const
  [
    (_) @constant
    (unit) @constant.builtin
  ])

(primary_constr_args (_) @variable.parameter)

(class_as_reference
  (_) @variable.parameter.builtin)

((argument_patterns (long_identifier (identifier) @character.special))
 (#match? @character.special "^\_.*"))

;; ----------------------------------------------------------------------------
;; Punctuation & Types

(type_name type_name: (_) @type.definition)

[
 (_type)
 (atomic_type)
] @type

(member_signature
  .
  (identifier) @function.member
  (curried_spec
    (arguments_spec
      "*"* @operator
      (argument_spec
        (argument_name_spec
          "?"? @character.special
          name: (_) @variable.parameter)))))

(union_type_case (identifier) @constant)

(rules
  (rule
    pattern: (_) @constant
    block: (_)))

(wildcard_pattern) @character.special

(identifier_pattern
  .
  (_) @constant
  .
  (_) @variable)

(optional_pattern
  "?" @character.special)

;; ----------------------------------------------------------------------------
;; Modules & Namespaces

(fsi_directive_decl . (string) @module)
(import_decl . (_) @module)
(named_module
  name: (_) @module)
(namespace
  name: (_) @module)
(module_defn
  .
  (_) @module)

(ce_expression
  .
  (_) @constant.macro)

(field_initializer
  field: (_) @property)

(record_fields
  (record_field
    .
    (identifier) @property))

(value_declaration_left . (_) @variable)

;; ----------------------------------------------------------------------------
;; Functions & Invocations

;; 1. Function Definitions (let twice, let privateTwice)
(function_declaration_left
  (access_modifier)?
  [
    (identifier) @function.method
    (op_identifier) @function.method
  ])

;; 2. Standard Function Invocations (List.map x)
(application_expression
  [
    (long_identifier_or_op) @function.call
    (dot_expression
      field: (long_identifier_or_op) @function.call)
  ] . (_)
)

;; 3. Forward Pipelines (|>, ||>, |||>)
(infix_expression
  (_)
  (infix_op) @_op
  [
    (long_identifier_or_op) @function.call
    (dot_expression field: (long_identifier_or_op) @function.call)
  ]
  (#match? @_op "^\\|{1,3}>$")
)

;; 4. Backward Pipelines (<|, <||, <|||)
(infix_expression
  [
    (long_identifier_or_op) @function.call
    (dot_expression field: (long_identifier_or_op) @function.call)
  ]
  (infix_op) @_op
  (_)
  (#match? @_op "^<\\|{1,3}$")
)

(argument_patterns) @variable.parameter

(typed_pattern
  (_pattern) @variable.parameter
  (_type) @type)

(member_defn
  (method_or_prop_defn
    [
      (property_or_ident) @function
      (property_or_ident
        instance: (identifier) @variable.parameter.builtin
        method: (identifier) @function.method)
    ]
    args: (_)* @variable.parameter))

(dot_expression
  .
  (_) @variable.member
  .
  (_))

;; ----------------------------------------------------------------------------
;; Numbers & Primitives

[
  (xint)
  (int)
  (int16)
  (uint16)
  (int32)
  (uint32)
  (int64)
  (uint64)
  (nativeint)
  (unativeint)
] @number

[
  (ieee32)
  (ieee64)
  (float)
  (decimal)
] @number.float

(bool) @boolean

([
  (string)
  (triple_quoted_string)
  (verbatim_string)
  (char)
] @string)

;; ----------------------------------------------------------------------------
;; Keywords & Operators

(compiler_directive_decl) @keyword.directive

(preproc_line
  "#line" @keyword.directive)

(attribute
  target: (identifier)? @keyword
  (_type) @attribute)

[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
  "[|"
  "|]"
  "{|"
  "|}"
] @punctuation.bracket

[
  "[<"
  ">]"
] @punctuation.special

(format_string_eval
  [
    "{"
    "}"
  ] @punctuation.special)

[
  ","
  ";"
  ":"
  "."
] @punctuation.delimiter

[
  "|"
  "="
  ">"
  "<"
  "-"
  "~"
  "->"
  "<-"
  "&"
  "&&"
  "||"
  ":>"
  ":?>"
  ".."
  (infix_op)
  (prefix_op)
  (op_identifier)
] @operator

(generic_type
  [
   "<"
   ">"
  ] @punctuation.bracket)

[
  "if"
  "then"
  "else"
  "elif"
  "when"
  "match"
  "match!"
] @keyword.conditional

[
  "or"
  "not"
  "upcast"
  "downcast"
] @keyword.operator

[
  "return"
  "return!"
  "yield"
  "yield!"
] @keyword.return

[
  "for"
  "while"
  "downto"
  "to"
] @keyword.repeat

[
  "open"
  "#r"
  "#load"
] @keyword.import

[
  "abstract"
  "delegate"
  "static"
  "inline"
  "mutable"
  "override"
  "rec"
  "global"
  (access_modifier)
] @keyword.modifier

[
  "let"
  "let!"
  "use"
  "use!"
  "member"
] @keyword.function

[
  "enum"
  "type"
  "inherit"
  "interface"
  "and"
  "class"
  "struct"
] @keyword

((identifier) @keyword.exception
 (#any-of? @keyword.exception "failwith" "failwithf" "raise" "reraise"))

[
  "as"
  "assert"
  "begin"
  "end"
  "done"
  "default"
  "in"
  "do"
  "do!"
  "fun"
  "function"
  "get"
  "set"
  "lazy"
  "new"
  "of"
  "val"
  "module"
  "namespace"
  "with"
] @keyword

[
  "null"
] @constant.builtin

(match_expression "with" @keyword.conditional)

(try_expression
  [
    "try"
    "with"
    "finally"
  ] @keyword.exception)

(preproc_if
  [
    "#if" @keyword.directive
    "#endif" @keyword.directive
  ]
  condition: (_)? @keyword.directive)

(preproc_else
  "#else" @keyword.directive)

((long_identifier
  (identifier)+ @variable.member
  .
  (identifier)))

;; Literal attribute highlighting
((value_declaration
   (attributes
     (attribute
       (_type
         (long_identifier
           (identifier) @attribute))))
   (function_or_value_defn
     (value_declaration_left
       .
       (_) @constant)))
 (#eq? @attribute "Literal"))
