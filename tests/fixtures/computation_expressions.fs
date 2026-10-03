let combine first second third =
    task {
        let! x = first
        and! y = second
        and! z = third
        while! ready = checkReady
        return x + y + z
    }

// and! and while! in comments and strings must remain comment/string content.
let example = "and! while!"
