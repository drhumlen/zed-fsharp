// Optional explicit F# delimiters, kept separate from the idiomatic examples.
let expression = begin 1 + 2 end

type Counter = class
    member _.Next() = 1
end

type ICounter = interface
    abstract member Next: unit -> int
end

type Point = struct
    val X: int
end

for value in [ 1; 2; 3 ] do
    ignore value
done

let mutable remaining = 3
while remaining > 0 do
    remaining <- remaining - 1
done
