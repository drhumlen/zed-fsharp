namespace Billing.Domain

module Rates =
    let apply rate amount =
        amount * rate

type Currency =
    | Nok
    | Eur
