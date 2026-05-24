; Re-inject the SQL grammar into PL/pgSQL function bodies (the text
; between `$$ ... $$`). Without this the body is one big string literal
; and renders as a single colour.

((function_body) @injection.content
  (#set! injection.language "sql")
  (#set! injection.include-children))

((dollar_quote) @injection.content
  (#set! injection.language "sql")
  (#set! injection.include-children))
