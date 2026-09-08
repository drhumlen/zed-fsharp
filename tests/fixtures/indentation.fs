module Indentation

let classify value =
    if value > 0 then
        "positive"
    elif value < 0 then
        "negative"
    else
        "zero"

let parse text =
    try
        int text
    with
    | _ -> 0

let cleanup action =
    try
        action ()
    finally
        printfn "finished"

let nested value =
    let increment x =
        x + 1
    increment value

let numbers =
    [|
        1
        2
    |]
