; Modules
(module_defn
  "module" @context
  (identifier) @name) @item

; Function bindings
(function_or_value_defn
  (function_declaration_left
    .
    (identifier) @name)) @item

(function_or_value_defn
  (value_declaration_left
    (identifier_pattern) @name)) @item

; Record fields
;(record_field
;  .
;  (identifier) @name) @item

; Union type cases
; (union_type_case
;   .
;   (identifier) @name) @item

; Methods
(member_defn
  "member" @context
  (method_or_prop_defn
    .
    (property_or_ident) @name)) @item

(type_definition
  "type" @context
  (record_type_defn
    (type_name) @name)) @item

(type_definition
  "type" @context
  (anon_type_defn
    (type_name) @name)) @item
