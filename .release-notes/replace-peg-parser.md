## Replace PEG parser with hand-rolled recursive descent

The internal statement parser has been rewritten from a PEG-based parser (using the `ponylang/peg` library) to a hand-rolled recursive descent parser. This removes the `ponylang/peg` transitive dependency from the library.

No template syntax, behavior, or public API has changed. Templates that parsed and rendered before will produce identical results. The only user-visible effect is that `ponylang/peg` is no longer pulled into your dependency tree.
