; Delimiter pairs
("(" @open
  ")" @close)

("[" @open
  "]" @close)

("[|" @open
  "|]" @close)

("{" @open
  "}" @close)

("{|" @open
  "|}" @close)

("[<" @open
  ">]" @close)

; F# block forms represented by explicit paired keywords.
(begin_end_expression
  "begin" @open
  "end" @close)

(anon_type_defn
  [
    "begin"
    "class"
    "struct"
  ] @open
  "end" @close)

(interface_type_defn
  "interface" @open
  "end" @close)

(for_expression
  "do" @open
  "done" @close)

(while_expression
  "do" @open
  "done" @close)

(block_comment
  "(*" @open
  "*)" @close)
