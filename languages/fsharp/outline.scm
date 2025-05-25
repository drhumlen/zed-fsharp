; Modules
(module_defn
  .
  (identifier) @name) @item

; Function bindings
(function_or_value_defn
  (function_declaration_left
    .
    (identifier) @name)) @item

; Record fields
(record_field
  .
  (identifier) @name) @item

; Union type cases
(union_type_case
  .
  (identifier) @name) @item

; Methods
(member_defn
  "member" @context
  (method_or_prop_defn
    .
    (property_or_ident) @name)) @item
