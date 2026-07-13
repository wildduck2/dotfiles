; Injections for SQL files. Empty -- the SQL grammar already parses
; PL/pgSQL bodies recursively, and re-injecting `sql` into
; (function_body) / (dollar_quote) triggers an infinite re-parse
; cycle (Lua stack overflow at languagetree.lua:1059).
