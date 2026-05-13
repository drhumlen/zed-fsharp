;; ============================================================================
;; Modules & Namespaces
;; ============================================================================

((namespace
  name: (long_identifier) @name) @item
 (#set! "kind" "namespace"))

((named_module
  name: (long_identifier) @name) @item
 (#set! "kind" "module"))

((module_defn
  (identifier) @name) @item
 (#set! "kind" "module"))

;; ============================================================================
;; Types & Classes
;; ============================================================================

((type_definition (record_type_defn (type_name (identifier) @name))) @item (#set! "kind" "struct"))
((type_definition (union_type_defn (type_name (identifier) @name))) @item (#set! "kind" "enum"))
((type_definition (enum_type_defn (type_name (identifier) @name))) @item (#set! "kind" "enum"))
((type_definition (anon_type_defn (type_name (identifier) @name))) @item (#set! "kind" "class"))
((type_definition (type_abbrev_defn (type_name (identifier) @name))) @item (#set! "kind" "type"))
((type_definition (delegate_type_defn (type_name (identifier) @name))) @item (#set! "kind" "interface"))

;; ============================================================================
;; Class Methods & Properties
;; ============================================================================

;; Standard methods and properties (member x.MyMethod)
((member_defn
  (method_or_prop_defn
    name: (property_or_ident
      [
        method: (identifier) @name
        (identifier) @name
        (op_identifier) @name
      ]))) @item
 (#set! "kind" "method"))

;; Abstract methods (abstract member MyMethod)
((member_defn
  (member_signature
    (identifier) @name)) @item
 (#set! "kind" "method"))

;; Union / Enum Cases
((union_type_case (identifier) @name) @item (#set! "kind" "variant"))
((enum_type_case (identifier) @name) @item (#set! "kind" "variant"))

;; ============================================================================
;; Top-Level & Module-Level Functions
;; ============================================================================
;; We strictly scope these to File/Namespace/Module parents to avoid picking
;; up internal/local helper functions declared inside other expressions.
;; F# Tree-sitter can alias top-level bindings, so we check both node types.

((file
  [
    (declaration_expression (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
    (value_declaration (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
  ])
 (#set! "kind" "function"))

((namespace
  [
    (declaration_expression (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
    (value_declaration (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
  ])
 (#set! "kind" "function"))

((named_module
  [
    (declaration_expression (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
    (value_declaration (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
  ])
 (#set! "kind" "function"))

((module_defn
  [
    (declaration_expression (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
    (value_declaration (function_or_value_defn (function_declaration_left [ (identifier) @name (op_identifier) @name ]))) @item
  ])
 (#set! "kind" "function"))

;; ============================================================================
;; Top-Level Variables
;; ============================================================================

((file
  [
    (declaration_expression (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
    (value_declaration (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
  ])
 (#set! "kind" "variable"))

((namespace
  [
    (declaration_expression (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
    (value_declaration (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
  ])
 (#set! "kind" "variable"))

((named_module
  [
    (declaration_expression (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
    (value_declaration (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
  ])
 (#set! "kind" "variable"))

((module_defn
  [
    (declaration_expression (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
    (value_declaration (function_or_value_defn (value_declaration_left (identifier_pattern (long_identifier_or_op) @name)))) @item
  ])
 (#set! "kind" "variable"))
