module Callbacks

let increment = fun value -> value + 1
let answer = 42

let positiveTotals groups =
    groups
    |> List.map (fun values ->
        values
        |> List.filter (fun value -> value > 0)
        |> List.sum)

let describe = function
    | Some value -> string value
    | None -> "missing"

let descriptions values =
    values
    |> List.map (function
        | Some value -> string value
        | None -> "missing")
