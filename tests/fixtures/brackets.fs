module Billing

type Order =
    { Id: int
      Prices: decimal list }

type Payment =
    | Card of string
    | Invoice

let order = { Id = 1; Prices = [ 12m; 8m; 5m ] }
let updatedOrder = { order with Prices = [ 10m; 20m ] }
let bytes = [| 1uy; 2uy |]
let pair = (order.Id, List.length order.Prices)
let summary = {| Id = order.Id; Total = List.sum order.Prices |}

let calculateTotal order =
    order.Prices
    |> List.filter (fun price -> price > 0m)
    |> List.sum

let describePayment payment =
    match payment with
    | Card number -> sprintf "Card %s" number
    | Invoice -> "Invoice"

type ICalculator =
    abstract member Calculate: Order -> decimal

type Calculator(discount: decimal) =
    member _.Calculate order =
        calculateTotal order * (1m - discount)

    static member Create() =
        Calculator(0m)

    interface ICalculator with
        member this.Calculate order =
            this.Calculate order

let printPrices order =
    for price in order.Prices do
        printfn "%M" price

let countDown count =
    let mutable remaining = count
    while remaining > 0 do
        remaining <- remaining - 1
    remaining

let loadTotal order =
    async {
        let! loaded = async.Return order
        return calculateTotal loaded
    }

(* Prices include tax. *)
module Reports =
    let totals orders =
        orders |> List.map calculateTotal

    let hasOrders orders =
        not (List.isEmpty orders)
