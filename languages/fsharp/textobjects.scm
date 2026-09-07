; Functions
;
; A `function_or_value_defn` uses `function_declaration_left` only when the
; binding has one or more argument patterns. Plain value bindings instead use
; `value_declaration_left`, so they are deliberately excluded here.
(function_or_value_defn
  (function_declaration_left)
  body: (_) @function.inside) @function.around

; `member_defn` covers instance members, static members, overrides, defaults,
; and property-like members. Include implemented properties as useful
; navigation targets alongside methods.
(member_defn
  (method_or_prop_defn)) @function.around

; In the generated parser, method implementation expressions are direct
; `_expression` children. This excludes the `args` pattern fields.
(method_or_prop_defn
  (_expression) @function.inside)

(property_accessor
  (_expression) @function.inside)

; Abstract members have no implementation body, but are still useful
; function-motion targets.
(member_defn
  (member_signature)) @function.around

; Classes, records, unions, interfaces, aliases, delegates, enums, and type
; extensions are all represented by `type_definition` at the structural level.
(type_definition) @class.around

(record_type_defn
  block: (record_fields) @class.inside)

(union_type_defn
  (union_type_cases) @class.inside)

(enum_type_defn
  (enum_type_cases) @class.inside)

(anon_type_defn
  "="
  ["begin" "class" "struct"]?
  (_)* @class.inside)

(interface_type_defn
  "interface"
  (_)* @class.inside)

(type_extension
  (type_extension_elements) @class.inside)

; Modules and namespaces are structural units too. `module_defn` has a block
; field; file-scoped modules and namespaces expose their contents as children.
; Keep body captures in one match so Zed joins them into one inside range.
; Module separators are anonymous `;` tokens, including indentation newlines.
(module_defn
  "="
  [(_) ";"]* @class.inside) @class.around

(named_module) @class.around

(namespace) @class.around

; Comments
(line_comment)+ @comment.around

(block_comment) @comment.around
