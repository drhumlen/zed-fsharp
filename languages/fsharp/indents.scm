; Zed uses @indent ranges, optionally bounded by @start and @end.
; Capture local let definitions without their following 'in' expression.
[
  (function_or_value_defn)
  (and_bang)
  (method_or_prop_defn)
  (property_accessor)
  (additional_constr_defn)
  (module_defn)
  (type_definition)
  (fun_expression)
  (function_expression)
  (for_expression)
  (while_expression)
  (match_expression)
  (rule)
  (do_expression)
] @indent

; Branch keywords delimit indentation ranges.
(if_expression
  "then" @start
  then: (_)
  .
  [(elif_expression) "else"]? @end) @indent

(elif_expression
  "then" @start) @indent

(if_expression
  "else" @start) @indent

(try_expression
  "try" @start
  ["with" "finally"] @end) @indent

(try_expression
  "finally" @start) @indent

(try_expression
  "with" @start) @indent

(match_expression
  "with" @start) @indent

; Closing delimiters align with their opening line.
(_ "(" ")" @end) @indent
(_ "[" "]" @end) @indent
(_ "[|" "|]" @end) @indent
(_ "{" "}" @end) @indent
(_ "{|" "|}" @end) @indent

(begin_end_expression
  "begin" @start
  "end" @end) @indent

(anon_type_defn
  ["begin" "class" "struct"] @start
  "end" @end) @indent

(interface_type_defn
  "interface" @start
  "end" @end) @indent
