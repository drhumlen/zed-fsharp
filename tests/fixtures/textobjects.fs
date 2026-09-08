// Module-level function
module Billing

let calculateTotal items =
    items
    |> List.sumBy _.Price

[<Literal>]
let answer = 42

let totalWithDiscount rate items =
    let discount price =
        price * (1m - rate)

    items
    |> List.sumBy (fun item -> discount item.Price)

type Order =
    {
        Id: System.Guid
        Items: string list
    }

type PaymentMethod =
    | Card of string
    | Invoice

type Calculator() =
    member _.Add x y =
        x + y

    static member Create() =
        Calculator()

module Nested =
    (* Nested function. *)
    let formatTotal amount =
        $"{amount:N2}"

    let identity value = value

type InlineUnion = First | Second
type InlineEnum = Zero = 0 | One = 1
