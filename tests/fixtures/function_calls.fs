module FunctionCalls

let sum = max 1 2 + min 3 4
let bounded value = System.Math.Max 0 value + System.Math.Min 100 value
let noRightCall value = max 1 2 + value
