; Injections for SQL files. PL/pgSQL bodies and SQL function bodies
; are ALREADY parsed by the sql grammar -- do NOT re-inject `sql`
; into them or treesitter recurses infinitely (stack overflow at
; languagetree.lua:1059).
;
; Future: inject `plpgsql` into PL/pgSQL bodies once a treesitter
; plpgsql grammar is bundled. Until then, leave the body as plain
; sql (the inner grammar still tokenises it).
