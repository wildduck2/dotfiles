(invocation
  (object_reference
    name: (identifier) @function.call))

[
  (keyword_gist)
  (keyword_btree)
  (keyword_hash)
  (keyword_spgist)
  (keyword_gin)
  (keyword_brin)
  (keyword_array)
  (keyword_object_id)
] @function.call

((object_reference
  name: (identifier) @type) @_obj_ref
  (#not-has-parent? @_obj_ref invocation))

(cte
  (identifier) @type)

(relation
  alias: (identifier) @variable)

(field
  name: (identifier) @variable.member)

(column_definition
  name: (identifier) @variable.member)

; Broader fallback for grammars where the `name:` field isn't tagged:
; first identifier child of column_definition is the column name.
((column_definition (identifier) @variable.member)
  (#set! "priority" 130))

; PG non-reserved words used as column names (role, name, user, type,
; ...) -- captured without the `name:` qualifier because the field
; may not be exposed.
((column_definition (keyword_role) @variable.member) (#set! "priority" 130))
((column_definition (keyword_name) @variable.member) (#set! "priority" 130))
((column_definition (keyword_user) @variable.member) (#set! "priority" 130))
((column_definition (keyword_type) @variable.member) (#set! "priority" 130))
((column_definition (keyword_schema) @variable.member) (#set! "priority" 130))
((column_definition (keyword_action) @variable.member) (#set! "priority" 130))
((column_definition (keyword_language) @variable.member) (#set! "priority" 130))
((column_definition (keyword_comment) @variable.member) (#set! "priority" 130))
((column_definition (keyword_owner) @variable.member) (#set! "priority" 130))
((column_definition (keyword_data) @variable.member) (#set! "priority" 130))
((column_definition (keyword_value) @variable.member) (#set! "priority" 130))
((column_definition (keyword_format) @variable.member) (#set! "priority" 130))
((column_definition (keyword_zone) @variable.member) (#set! "priority" 130))
((column_definition (keyword_database) @variable.member) (#set! "priority" 130))

(term
  alias: (identifier) @variable)

(term
  value: (cast
    name: (keyword_cast) @function.call
    parameter: (literal)?))

(literal) @string

(comment) @comment @spell

(marginalia) @comment

((literal) @number
  (#lua-match? @number "^%d+$"))

((literal) @number.float
  (#lua-match? @number.float "^[-]?%d*%.%d*$"))

(parameter) @variable.parameter

[
  (keyword_true)
  (keyword_false)
] @boolean

[
  (keyword_asc)
  (keyword_desc)
  (keyword_terminated)
  (keyword_escaped)
  (keyword_unsigned)
  (keyword_nulls)
  (keyword_last)
  (keyword_delimited)
  (keyword_replication)
  (keyword_auto_increment)
  (keyword_default)
  (keyword_collate)
  (keyword_concurrently)
  (keyword_engine)
  (keyword_always)
  (keyword_generated)
  (keyword_preceding)
  (keyword_following)
  (keyword_first)
  (keyword_current_timestamp)
  (keyword_immutable)
  (keyword_atomic)
  (keyword_parallel)
  (keyword_leakproof)
  (keyword_safe)
  (keyword_cost)
  (keyword_strict)
] @attribute

[
  (keyword_materialized)
  (keyword_recursive)
  (keyword_temp)
  (keyword_temporary)
  (keyword_unlogged)
  (keyword_external)
  (keyword_parquet)
  (keyword_csv)
  (keyword_rcfile)
  (keyword_textfile)
  (keyword_orc)
  (keyword_avro)
  (keyword_jsonfile)
  (keyword_sequencefile)
  (keyword_volatile)
] @keyword.modifier

[
  (keyword_case)
  (keyword_when)
  (keyword_then)
  (keyword_else)
] @keyword.conditional

[
  (keyword_select)
  (keyword_from)
  (keyword_where)
  (keyword_index)
  (keyword_join)
  (keyword_primary)
  (keyword_delete)
  (keyword_create)
  (keyword_show)
  (keyword_unload)
  (keyword_insert)
  (keyword_merge)
  (keyword_distinct)
  (keyword_replace)
  (keyword_update)
  (keyword_into)
  (keyword_overwrite)
  (keyword_matched)
  (keyword_values)
  (keyword_value)
  (keyword_attribute)
  (keyword_set)
  (keyword_left)
  (keyword_right)
  (keyword_outer)
  (keyword_inner)
  (keyword_full)
  (keyword_order)
  (keyword_partition)
  (keyword_group)
  (keyword_with)
  (keyword_without)
  (keyword_as)
  (keyword_having)
  (keyword_limit)
  (keyword_offset)
  (keyword_table)
  (keyword_tables)
  (keyword_key)
  (keyword_references)
  (keyword_foreign)
  (keyword_constraint)
  (keyword_force)
  (keyword_use)
  (keyword_include)
  (keyword_for)
  (keyword_if)
  (keyword_exists)
  (keyword_column)
  (keyword_columns)
  (keyword_cross)
  (keyword_lateral)
  (keyword_natural)
  (keyword_alter)
  (keyword_drop)
  (keyword_add)
  (keyword_view)
  (keyword_end)
  (keyword_is)
  (keyword_using)
  (keyword_between)
  (keyword_window)
  (keyword_no)
  (keyword_data)
  (keyword_type)
  (keyword_rename)
  (keyword_to)
  (keyword_schema)
  (keyword_owner)
  (keyword_authorization)
  (keyword_all)
  (keyword_any)
  (keyword_some)
  (keyword_returning)
  (keyword_begin)
  (keyword_commit)
  (keyword_rollback)
  (keyword_transaction)
  (keyword_only)
  (keyword_like)
  (keyword_similar)
  (keyword_over)
  (keyword_change)
  (keyword_modify)
  (keyword_after)
  (keyword_before)
  (keyword_range)
  (keyword_rows)
  (keyword_groups)
  (keyword_exclude)
  (keyword_current)
  (keyword_ties)
  (keyword_others)
  (keyword_zerofill)
  (keyword_format)
  (keyword_fields)
  (keyword_row)
  (keyword_sort)
  (keyword_compute)
  (keyword_comment)
  (keyword_location)
  (keyword_cached)
  (keyword_uncached)
  (keyword_lines)
  (keyword_stored)
  (keyword_virtual)
  (keyword_partitioned)
  (keyword_analyze)
  (keyword_explain)
  (keyword_verbose)
  (keyword_truncate)
  (keyword_rewrite)
  (keyword_optimize)
  (keyword_vacuum)
  (keyword_cache)
  (keyword_language)
  (keyword_called)
  (keyword_conflict)
  (keyword_declare)
  (keyword_filter)
  (keyword_function)
  (keyword_input)
  (keyword_name)
  (keyword_oid)
  (keyword_oids)
  (keyword_precision)
  (keyword_regclass)
  (keyword_regnamespace)
  (keyword_regproc)
  (keyword_regtype)
  (keyword_restricted)
  (keyword_return)
  (keyword_returns)
  (keyword_separator)
  (keyword_setof)
  (keyword_stable)
  (keyword_support)
  (keyword_tblproperties)
  (keyword_trigger)
  (keyword_unsafe)
  (keyword_admin)
  (keyword_connection)
  (keyword_cycle)
  (keyword_database)
  (keyword_encrypted)
  (keyword_increment)
  (keyword_logged)
  (keyword_none)
  (keyword_owned)
  (keyword_password)
  (keyword_reset)
  (keyword_role)
  (keyword_sequence)
  (keyword_start)
  (keyword_restart)
  (keyword_tablespace)
  (keyword_split)
  (keyword_tablets)
  (keyword_until)
  (keyword_user)
  (keyword_valid)
  (keyword_action)
  (keyword_definer)
  (keyword_invoker)
  (keyword_security)
  (keyword_extension)
  (keyword_version)
  (keyword_out)
  (keyword_inout)
  (keyword_variadic)
  (keyword_ordinality)
  (keyword_session)
  (keyword_isolation)
  (keyword_level)
  (keyword_serializable)
  (keyword_repeatable)
  (keyword_read)
  (keyword_write)
  (keyword_committed)
  (keyword_uncommitted)
  (keyword_deferrable)
  (keyword_names)
  (keyword_zone)
  (keyword_immediate)
  (keyword_deferred)
  (keyword_constraints)
  (keyword_snapshot)
  (keyword_characteristics)
  (keyword_off)
  (keyword_follows)
  (keyword_precedes)
  (keyword_each)
  (keyword_instead)
  (keyword_of)
  (keyword_initially)
  (keyword_old)
  (keyword_new)
  (keyword_referencing)
  (keyword_statement)
  (keyword_execute)
  (keyword_procedure)
  (keyword_copy)
  (keyword_delimiter)
  (keyword_encoding)
  (keyword_escape)
  (keyword_force_not_null)
  (keyword_force_null)
  (keyword_force_quote)
  (keyword_freeze)
  (keyword_header)
  (keyword_match)
  (keyword_program)
  (keyword_quote)
  (keyword_stdin)
  (keyword_extended)
  (keyword_main)
  (keyword_plain)
  (keyword_storage)
  (keyword_compression)
  (keyword_duplicate)
] @keyword

(keyword_while) @keyword.repeat

[
  (keyword_unbounded)
  (keyword_delayed)
  (keyword_high_priority)
  (keyword_low_priority)
  (keyword_ignore)
  (keyword_nothing)
  (keyword_option)
  (keyword_local)
  (keyword_cascaded)
  (keyword_wait)
  (keyword_nowait)
  (keyword_metadata)
  (keyword_incremental)
  (keyword_bin_pack)
  (keyword_noscan)
  (keyword_stats)
  (keyword_statistics)
  (keyword_maxvalue)
  (keyword_minvalue)
] @keyword.modifier

; UNIQUE / CHECK / CASCADE / RESTRICT moved out of @keyword.modifier
; into @keyword so they read the same italic purple as PRIMARY KEY /
; FOREIGN KEY / REFERENCES (constraint statements should share one
; visual register). High priority so no upstream capture downgrades
; them.
((keyword_unique)     @keyword (#set! "priority" 150))
((keyword_check)      @keyword (#set! "priority" 150))
((keyword_cascade)    @keyword (#set! "priority" 150))
((keyword_restrict)   @keyword (#set! "priority" 150))
((keyword_foreign)    @keyword (#set! "priority" 150))
((keyword_primary)    @keyword (#set! "priority" 150))
((keyword_key)        @keyword (#set! "priority" 150))
((keyword_references) @keyword (#set! "priority" 150))

[
  (keyword_int)
  (keyword_null)
  (keyword_boolean)
  (keyword_binary)
  (keyword_varbinary)
  (keyword_image)
  (keyword_bit)
  (keyword_inet)
  (keyword_character)
  (keyword_smallserial)
  (keyword_serial)
  (keyword_bigserial)
  (keyword_smallint)
  (keyword_mediumint)
  (keyword_bigint)
  (keyword_tinyint)
  (keyword_decimal)
  (keyword_float)
  (keyword_double)
  (keyword_numeric)
  (keyword_real)
  (double)
  (keyword_money)
  (keyword_smallmoney)
  (keyword_char)
  (keyword_nchar)
  (keyword_varchar)
  (keyword_nvarchar)
  (keyword_varying)
  (keyword_text)
  (keyword_string)
  (keyword_uuid)
  (keyword_json)
  (keyword_jsonb)
  (keyword_xml)
  (keyword_bytea)
  (keyword_enum)
  (keyword_date)
  (keyword_datetime)
  (keyword_time)
  (keyword_datetime2)
  (keyword_datetimeoffset)
  (keyword_smalldatetime)
  (keyword_timestamp)
  (keyword_timestamptz)
  (keyword_geometry)
  (keyword_geography)
  (keyword_box2d)
  (keyword_box3d)
  (keyword_interval)
] @type.builtin

[
  (keyword_in)
  (keyword_and)
  (keyword_or)
  (keyword_not)
  (keyword_by)
  (keyword_on)
  (keyword_do)
  (keyword_union)
  (keyword_except)
  (keyword_intersect)
] @keyword.operator

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "^"
  ":="
  "="
  "<"
  "<="
  "!="
  ">="
  ">"
  "<>"
  (op_other)
  (op_unary_other)
] @operator

[
  "("
  ")"
] @punctuation.bracket

[
  ";"
  ","
  "."
] @punctuation.delimiter
; SQL highlights extras -- additive over the upstream queries shipped
; with nvim-treesitter. Uses only standard treesitter capture names so
; the active colorscheme styles them naturally. No custom hl groups.

; -----------------------------------------------------------------------
; PG "non-reserved" words used as identifiers (role, name, user, type,
; schema, ...). Tree-sitter tokenises them as `keyword_*` even in
; column-name position. Re-capture as @variable.member so they read
; like the surrounding columns.
; -----------------------------------------------------------------------

(column_definition name: (keyword_role) @variable.member)
(column_definition name: (keyword_name) @variable.member)
(column_definition name: (keyword_user) @variable.member)
(column_definition name: (keyword_type) @variable.member)
(column_definition name: (keyword_schema) @variable.member)
(column_definition name: (keyword_action) @variable.member)
(column_definition name: (keyword_language) @variable.member)
(column_definition name: (keyword_comment) @variable.member)
(column_definition name: (keyword_owner) @variable.member)
(column_definition name: (keyword_data) @variable.member)
(column_definition name: (keyword_value) @variable.member)
(column_definition name: (keyword_format) @variable.member)
(column_definition name: (keyword_zone) @variable.member)
(column_definition name: (keyword_database) @variable.member)
(column_definition name: (keyword_password) @variable.member)
(column_definition name: (keyword_session) @variable.member)
(column_definition name: (keyword_version) @variable.member)

; `field` node's `name:` slot only accepts `(identifier)` per the
; grammar, so we can't target keyword_* nodes there. The
; `column_definition` patterns above already cover the column-name
; case; `field` references to keyword_* nodes stay coloured by their
; underlying @keyword capture, which is the right semantics anyway
; (a SELECT projection of `role` is reading a column whose name
; happens to be a reserved-ish word -- it still parses as the keyword
; node tree-side).

; -----------------------------------------------------------------------
; Trigger row aliases NEW / OLD -- promote to @variable.builtin so the
; colorscheme styles them like other row bindings.
; -----------------------------------------------------------------------

(keyword_new) @variable.builtin
(keyword_old) @variable.builtin

; PL/pgSQL trigger row aliases NEW / OLD parse as bare identifiers in
; field/object_reference position. Re-capture so they read the same as
; the keyword_new / keyword_old captures above.
((object_reference name: (identifier) @variable.builtin)
  (#any-of? @variable.builtin "new" "NEW" "New" "old" "OLD" "Old")
  (#set! "priority" 200))

; `LANGUAGE plpgsql` -- colour the language identifier as a string so
; it pops against the surrounding keywords.
(function_language (identifier) @string
  (#set! "priority" 150))

; ----------------------------------------------------------------------
; PL/pgSQL keywords introduced by local grammar patches.
; ----------------------------------------------------------------------

[
  (keyword_elsif)
  (keyword_elseif)
] @keyword.conditional

[
  (keyword_raise)
  (keyword_exception)
  (keyword_notice)
  (keyword_warning)
  (keyword_info)
  (keyword_log)
  (keyword_debug)
  (keyword_get)
  (keyword_diagnostics)
  (keyword_stacked)
  (keyword_perform)
  (keyword_continue)
  (keyword_exit)
] @keyword

; -----------------------------------------------------------------------
; Dollar-quote delimiters ($$, $body$).
; -----------------------------------------------------------------------

(dollar_quote) @punctuation.special

; -----------------------------------------------------------------------
; PL/pgSQL assignment operator `:=`.
; -----------------------------------------------------------------------

(":=") @operator

; -----------------------------------------------------------------------
; UNIQUE / PRIMARY / FOREIGN / CHECK / REFERENCES / CASCADE land in
; @keyword (italic purple in tokyonight) instead of the dim
; @keyword.modifier upstream picks. Both priority syntaxes set so we
; cover every nvim treesitter version.
; -----------------------------------------------------------------------

; Duplicates of the priority-150 block above. Removed -- the higher
; priority earlier in the file is the authoritative capture.

; =====================================================================
; CONSTRAINT clause -- the canonical encapsulated block.
;
; Parser shape (verified against installed grammar):
;
;   (constraint
;     (keyword_constraint)
;     name: (identifier)                       <- constraint name
;     (keyword_primary|foreign|unique|check)
;     (keyword_key)
;     (ordered_columns
;       (column name: (identifier|keyword_*))) <- column refs in parens
;     [(keyword_references)
;      (object_reference name: (identifier))   <- referenced table
;      (ordered_columns ...)
;      (keyword_on) (keyword_delete|update)
;      (keyword_cascade|restrict|set|null|...)])
;
; Rules use the visible field paths and priority 150 so they win over
; every upstream/generic capture above.
; =====================================================================

; Constraint name -> @number (orange).
(constraint name: (identifier) @number
  (#set! "priority" 150))

; Sibling fallback: parser error-recovery occasionally demotes a
; constraint into an ERROR node. The constraint name then loses its
; `name:` field. Match any identifier inside ERROR alongside
; keyword_constraint so we still colour those orange.
(ERROR
  (keyword_constraint)
  (identifier) @number
  (#set! "priority" 155))

; Column references inside `(...)` paren lists -- includes PG
; non-reserved words tokenised as keyword_* nodes.
(constraint
  (ordered_columns
    (column
      name: [
        (identifier)
        (keyword_role)
        (keyword_name)
        (keyword_user)
        (keyword_type)
        (keyword_schema)
        (keyword_action)
        (keyword_language)
        (keyword_comment)
        (keyword_owner)
        (keyword_data)
        (keyword_value)
        (keyword_format)
        (keyword_zone)
        (keyword_database)
        (keyword_password)
        (keyword_session)
        (keyword_version)
      ] @variable.member))
  (#set! "priority" 150))

; Referenced table inside `REFERENCES tbl (cols)` -> @type.
(constraint
  (object_reference name: (identifier) @type)
  (#set! "priority" 150))

; Bare identifiers nested directly under constraint (CHECK expressions,
; error-recovery branches where the parser dropped ordered_columns) get
; treated as column refs. **EXCLUDE identifiers inside an invocation**
; (function call) -- those are function names and must keep their
; @function.call colour assigned earlier in the file.
((identifier) @variable.member
  (#has-ancestor? @variable.member constraint)
  (#not-has-ancestor? @variable.member invocation)
  (#set! "priority" 140))

; PG non-reserved keywords used as column refs inside CHECK / error
; branches that bypass the ordered_columns path above.
([
  (keyword_role)
  (keyword_name)
  (keyword_user)
  (keyword_type)
  (keyword_schema)
  (keyword_action)
  (keyword_language)
  (keyword_comment)
  (keyword_owner)
  (keyword_data)
  (keyword_value)
  (keyword_format)
  (keyword_zone)
  (keyword_database)
  (keyword_password)
  (keyword_session)
  (keyword_version)
] @variable.member
  (#has-ancestor? @variable.member constraint)
  (#set! "priority" 140))

; =====================================================================
; CREATE INDEX -- parallel rules.
; =====================================================================

((create_index (identifier) @number)
  (#set! "priority" 145))

((identifier) @variable.member
  (#has-ancestor? @variable.member create_index)
  (#not-has-ancestor? @variable.member invocation)
  (#set! "priority" 125))

((object_reference name: (identifier) @type)
  (#has-ancestor? @type create_index)
  (#set! "priority" 135))

; =====================================================================
; Generic CREATE TABLE column captures (covers inline column defs;
; column_definition rules earlier in the file handle the `name:` slot).
; =====================================================================

((create_table
  (_ (_ (identifier) @variable.member)))
  (#set! "priority" 140))
((create_table
  (_ (_ (_ (identifier) @variable.member))))
  (#set! "priority" 140))

; Relation refs in FROM / JOIN / DELETE FROM etc.
((relation (object_reference name: (identifier) @type))
  (#set! "priority" 130))

; -----------------------------------------------------------------------
; Fallback identifier classification when the grammar emits a bare
; (identifier) -- usually because the user typed something the lexer
; didn't recognise as a keyword.
; -----------------------------------------------------------------------

((identifier) @keyword
  (#lua-match? @keyword "^[Cc][Oo][Nn][Ss][Tt][Rr][Aa][Ii][Nn][Tt]$"))

((identifier) @keyword
  (#any-of? @keyword
    "constraint" "CONSTRAINT" "Constraint"
    "foreign" "FOREIGN" "Foreign"
    "primary" "PRIMARY" "Primary"
    "unique" "UNIQUE" "Unique"
    "check" "CHECK" "Check"
    "key" "KEY" "Key"
    "references" "REFERENCES" "References"
    "cascade" "CASCADE" "Cascade"
    "restrict" "RESTRICT" "Restrict"
    "deferrable" "DEFERRABLE" "Deferrable"
    "initially" "INITIALLY" "Initially"
    "deferred" "DEFERRED" "Deferred"
    "immediate" "IMMEDIATE" "Immediate"
    "materialized" "MATERIALIZED" "Materialized"
    "foreign" "FOREIGN" "Foreign"
    "primary" "PRIMARY" "Primary"
    "unique" "UNIQUE" "Unique"
    "check" "CHECK" "Check"
    "exclude" "EXCLUDE" "Exclude"
    "using" "USING" "Using"
    "trigger" "TRIGGER" "Trigger"
    "function" "FUNCTION" "Function"
    "procedure" "PROCEDURE" "Procedure"
    "language" "LANGUAGE" "Language"
    "returns" "RETURNS" "Returns"
    "stable" "STABLE" "Stable"
    "immutable" "IMMUTABLE" "Immutable"
    "volatile" "VOLATILE" "Volatile"
    "or" "OR" "Or"
    "replace" "REPLACE" "Replace"
    "generated" "GENERATED" "Generated"
    "always" "ALWAYS" "Always"
    "identity" "IDENTITY" "Identity"
    "stored" "STORED" "Stored"))

((identifier) @type.builtin
  (#any-of? @type.builtin
    "text" "TEXT" "Text"
    "int" "INT" "Int"
    "integer" "INTEGER" "Integer"
    "int4" "INT4" "int8" "INT8" "int2" "INT2"
    "bigint" "BIGINT" "smallint" "SMALLINT"
    "boolean" "BOOLEAN" "bool" "BOOL"
    "numeric" "NUMERIC" "decimal" "DECIMAL"
    "real" "REAL" "double" "DOUBLE" "float" "FLOAT"
    "float4" "FLOAT4" "float8" "FLOAT8"
    "uuid" "UUID" "date" "DATE" "time" "TIME"
    "timestamp" "TIMESTAMP" "timestamptz" "TIMESTAMPTZ"
    "interval" "INTERVAL"
    "json" "JSON" "jsonb" "JSONB" "bytea" "BYTEA"
    "varchar" "VARCHAR" "char" "CHAR"
    "character" "CHARACTER" "varying" "VARYING"
    "inet" "INET" "cidr" "CIDR" "macaddr" "MACADDR"
    "tsvector" "TSVECTOR" "tsquery" "TSQUERY"
    "point" "POINT" "line" "LINE" "box" "BOX"
    "polygon" "POLYGON" "circle" "CIRCLE"
    "money" "MONEY" "citext" "CITEXT"
    "serial" "SERIAL" "bigserial" "BIGSERIAL"
    "oid" "OID" "xml" "XML"
    "btree" "BTREE" "hash" "HASH" "gin" "GIN"
    "gist" "GIST" "brin" "BRIN" "spgist" "SPGIST"))
