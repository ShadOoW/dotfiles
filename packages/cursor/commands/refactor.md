# Refactor

Complete review. Improve structure and clarity without changing behavior.

**Find and fix**
- Outdated, redundant, unused code
- Duplicates, repeated patterns, shared behaviors
- Opportunities to simplify: more functional, dynamic, meta, declarative, clean, elegant
- Apply DRY. Prefer shared behavior over copy-paste

**Structure**
- Fewer DOM nesting. Fewer nested blocks in general
- Reuse styles. Fewer style definitions overall
- Design data structure for consumption pattern when it helps

**Avoid**
- `let`. Prefer `const`, expressions, small functions
- Nested blocks and nested conditions
- `else` and `else if`. Return early instead
- Long condition statements. Extract or invert
- Over-abstraction. One clear layer is enough
- Many try/catch. Prefer one central try/catch

**Prefer**
- Early returns to avoid nesting
- `map` / `reduce` where they fit
- Proxies where they fit
