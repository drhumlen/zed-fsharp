module Editing

[<Literal>]
let DefaultPort = 8080

[<System.Obsolete("Use DefaultPort")>]
let oldPort = DefaultPort

let identity<'T> (value: 'T) = value
let value' = identity 42
let initial = 'F'

let numbers = [| 1; 2; 3 |]
let summary = {| Count = numbers.Length; First = numbers.[0] |}

(* A block comment with (* a nested comment *) inside. *)
