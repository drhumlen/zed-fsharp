module InterpolatedStrings

let expirySlug = "2026-09-08"
let href = $"/options/details/{expirySlug}"
let details = $"Expires {expirySlug.ToUpperInvariant()} after {1 + 2} days"

let render expirySlug =
    _href $"/options/details/{expirySlug}"
