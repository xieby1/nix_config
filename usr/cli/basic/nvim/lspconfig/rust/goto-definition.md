# Rust-Analyzer Go-to-Definition Quirks with Operators

## Summary

When using `gd` (go-to-definition) in Neovim with rust-analyzer, you may find that placing the cursor on certain operators (e.g. `[` in `v["name"]`) jumps to the definition of an adjacent identifier instead of the operator's trait implementation.

### Root Cause: `pick_best_token` Scoring

In `crates/ide/src/goto_definition.rs`, rust-analyzer uses `pick_best_token` to select which syntax token at the cursor position should be resolved:

```rust
let original_token = pick_best_token(file.token_at_offset(offset), |kind| match kind {
    IDENT | INT_NUMBER | LIFETIME_IDENT | T![self] | T![super] | T![crate] | T![Self] | COMMENT => 4,
    // index and prefix ops
    T!['['] | T![']'] | T![?] | T![*] | T![-] | T![!] => 3,
    kind if kind.is_keyword(edition) => 2,
    T!['('] | T![')'] => 2,
    kind if kind.is_trivia() => 0,
    _ => 1,
})?;
```

The problem: LSP positions are zero-based character offsets. When your cursor is **on** a single-character operator (e.g. `[`), the sent position is technically the boundary **before** that character. At this boundary, `token_at_offset` returns **both** the preceding identifier and the operator. Since `IDENT` scores **4** and `[` scores only **3**, `pick_best_token` chooses the identifier — so rust-analyzer resolves the variable instead of the `IndexExpr`.

This only affects **single-character tokens** that share a boundary with higher-scored tokens. Multi-character operators like `!=`, `..`, `+=` are usually safe because the cursor falls *inside* the token, not at a boundary.

---

## Token Score Reference

| Token Kind | Score | Examples |
|---|---|---|
| Identifiers, numbers, `self`, `super`, `crate`, `Self`, comments | 4 | `foo`, `123`, `// comment` |
| Brackets `[` `]`, `?`, `*`, `-`, `!` | 3 | `v[idx]`, `*ptr`, `-x`, `foo!()` |
| Keywords, `(` `)` | 2 | `fn`, `let`, `await`, `(`, `)` |
| Other operators | 1 | `+`, `/`, `%`, `=`, `.`, `>` |
| Whitespace / trivia | 0 | spaces, newlines, tabs |

---

## Practical Tricks and Examples

### Index Operator `[]`

**Problem:** Cursor on `[` in `v["name"]` goes to definition of `v`.

| Cursor Position | What Happens | Why |
|---|---|---|
| On `[` | Goes to `v` | Boundary after `v` (4) vs `[` (3) |
| On `"` | **Goes to `Index::index`** | Boundary after `[` (3) vs `"` (1) |
| On `]` | **Goes to `Index::index`** | Boundary after `"` (1) vs `]` (3) |

**Trick:** Use `]` or the opening `"` of the index expression instead of `[`.

```rust
let x = v["name"];
//        ^ put cursor here (on `]`) for Index trait
//         ^ or here (on `"`) also works
```

For `v[idx]` where `idx` is an identifier:
- Cursor on `idx` -> boundary after `[` (3) vs `idx` (4) -> goes to `idx`
- **Cursor on `]` -> goes to `Index::index`**

---

### Binary Operators (`+`, `-`, `*`, `/`, `%`)

**Problem:** Cursor on `+` in `a + b` goes to definition of `a`.

| Cursor Position | What Happens | Why |
|---|---|---|
| On `a` | Goes to `a` | It's an identifier (4) |
| On `+` | Goes to `a` | Boundary after `a` (4) vs `+` (1) |
| On space **after** `+` | **Goes to `Add::add`** | Boundary after `+` (1) vs space (0) |
| On `b` | Goes to `b` | It's an identifier (4) |

**Trick:** Place the cursor on the whitespace **immediately after** the operator.

```rust
let sum = a + b;
//            ^ cursor on this space -> goes to Add trait
```

**Note:** This requires spaces around the operator (which `rustfmt` enforces). For `a+b` without spaces, there is no cursor position that selects `+` over the operands.

---

### Comparison Operators (`>`, `<`, `==`, `!=`)

Rust-analyzer has special handling (`find_definition_for_comparison_operators`) for `!=`, `<`, `<=`, `>`, `>=`, but `pick_best_token` can still steal the token.

| Operator | Cursor On | Result |
|---|---|---|
| `>` | `>` itself | Boundary after left operand -> left operand wins (4 vs 1) |
| `>` | Space after `>` | **Goes to `PartialOrd::partial_cmp`** (1 vs 0) |
| `!=` | `!` inside token | Usually safe (multi-char token, inside `!=`) |

**Trick:** Same as binary operators — use the whitespace after the operator.

```rust
if a > b {
//      ^ cursor on this space -> goes to PartialOrd
}
```

---

### Prefix Operators (`-`, `*`, `!`)

| Operator | Cursor On | Result |
|---|---|---|
| `-x` | On `-` | Boundary before `-` (start of expr) -> usually only `-` is returned, so this **often works** |
| `!x` | On `!` | Similar to `-`, usually works |
| `*ptr` | On `*` | Usually works |

Prefix operators are generally safer because there is no high-scoring identifier to the left inside the same expression. However, in contexts like `a * b` (binary), the same rules as binary operators apply.

---

### Try Operator `?`

| Cursor Position | Result |
|---|---|
| On `?` | Usually works (score 3, often no higher-scored neighbor to the left at the same boundary) |
| On space after `?` | **Goes to `From::from`** (if applicable) |

```rust
let x = maybe_value?;
//                    ^ cursor on this space -> goes to From trait
```

---

### Macro Invocation `!`

For `foo!()`, cursor on `!` sits at the boundary between `foo` and `!`. `foo` (4) beats `!` (3), so `pick_best_token` selects `foo`. **This is actually fine** because both tokens resolve to the same macro definition.

---

## General Rule

When go-to-definition on a single-character operator sends you to the wrong place:

1. **Move one character to the right** (onto whitespace or the next token). If the operator scores higher than what you land on, rust-analyzer will "fall back" to the operator.
2. **For `[]`, prefer `]` over `[`.**
3. **For binary operators, prefer the whitespace immediately after the operator.**

---

## Limitations

- **Compact code without spaces** (e.g. `a+b`) offers no reliable cursor position for binary operators, because every boundary has the operator (score 1) competing with an identifier (score 4).
- This behavior is inherent to rust-analyzer's `goto_definition` token selection. The ideal fix is upstream in rust-analyzer: `pick_best_token` should consider whether the offset unambiguously belongs to a lower-scored token when the user is clearly targeting it.
