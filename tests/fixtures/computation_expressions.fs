module ComputationExpressions

let combine first second third =
    task {
        let! x = first
        and! y = second
        and! z = third
        return x + y + z
    }

// and! in comments and strings must remain comment/string content.
let example = "and!"
