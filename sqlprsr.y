/* Based on original source code:
 *
 * Companion source code for "flex & bison", published by O'Reilly
 * Media, ISBN 978-0-596-15597-1
 * Copyright (c) 2009, Taughannock Networks. All rights reserved.
 * See the README file for license conditions and contact info.
 * $Header: /home/johnl/flnb/code/sql/RCS/lpmysql.y,v 2.1 2009/11/08 02:53:39 johnl Exp $
 */
/*
 * Parser for Calcite-Dremio SQL dialect
 * (Revisions by Roger Voss, May-June 2019)
 */
%{
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#if defined(_WIN32)
#include <malloc.h>
#else
#include <alloca.h>
#define _alloca alloca
#endif

extern int yylex (void);

char* concat_strings(char *s1, char *s2, char *s3);

 %}

%code requires {
char *filename;

typedef struct YYLTYPE {
  int first_line;
  int first_column;
  int last_line;
  int last_column;
  char *filename;
} YYLTYPE;
# define YYLTYPE_IS_DECLARED 1

# define YYLLOC_DEFAULT(Current, Rhs, N)        \
    do                  \
      if (N)                                                            \
  {                \
    (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;  \
    (Current).first_column = YYRHSLOC (Rhs, 1).first_column;  \
    (Current).last_line    = YYRHSLOC (Rhs, N).last_line;    \
    (Current).last_column  = YYRHSLOC (Rhs, N).last_column;  \
    (Current).filename     = YYRHSLOC (Rhs, 1).filename;          \
  }                \
      else                \
  { /* empty RHS */            \
    (Current).first_line   = (Current).last_line   =    \
      YYRHSLOC (Rhs, 0).last_line;        \
    (Current).first_column = (Current).last_column =    \
      YYRHSLOC (Rhs, 0).last_column;        \
    (Current).filename  = NULL;          \
  }                \
    while (0)
}


%union {
  int intval;
  double floatval;
  char *strval;
  int subtok;
}
  
  /* names and literal values */

%token <strval> NAME
%token <strval> STRING
%token <intval> INTNUM
%token <intval> BOOL
%token <floatval> APPROXNUM

       /* user @abc names */

%token <strval> USERVAR

       /* operators and precedence levels */

%nonassoc NIL
%left WITH ORDER LIMIT
%right ASSIGN
%left OR
%left XOR
%left ANDOP
%nonassoc IN IS LIKE REGEXP
%left NOT '!'
%left BETWEEN
%left <subtok> COMPARISON /* = <> < > <= >= <=> */
%left '|'
%left '&'
%left <subtok> SHIFT /* << >> */
%left '+' '-' UNION EXCEPT MINUS INTERSECT
%left '*' '/' '%' MOD
%left '^'
%nonassoc UMINUS

%token ADD
%token ALL
%token ALTER
%token ANALYZE
%token AND
%token ANY
%token AS
%token ASC
%token AUTO_INCREMENT
%token BEFORE
%token BETWEEN
%token BIGINT
%token BINARY
%token BIT
%token BLOB
%token BOTH
%token BY
%token CALL
%token CASCADE
%token CASE
%token CHANGE
%token CHAR
%token CHECK
%token COLLATE
%token COLUMN
%token COMMENT
%token CONDITION
%token CONSTRAINT
%token CONTINUE
%token CONVERT
%token CREATE
%token CROSS
%token CURRENT_DATE
%token CURRENT_TIME
%token CURRENT_TIMESTAMP
%token CURRENT_USER
%token CURSOR
%token DATABASE
%token DATABASES
%token DATE
%token DATETIME
%token DAY_HOUR
%token DAY_MICROSECOND
%token DAY_MINUTE
%token DAY_SECOND
%token DECIMAL
%token DECLARE
%token DEFAULT
%token DELAYED
%token DELETE
%token DESC
%token DESCRIBE
%token DETERMINISTIC
%token DISTINCT
%token DISTINCTROW
%token DIV
%token DOUBLE
%token DROP
%token DUAL
%token EACH
%token ELSE
%token ELSEIF
%token ENCLOSED
%token END
%token ENUM
%token ESCAPED
%token <subtok> EXISTS
%token EXIT
%token EXPLAIN
%token FETCH
%token FLOAT
%token FOR
%token FORCE
%token FOREIGN
%token FROM
%token FULLTEXT
%token GRANT
%token GROUP
%token HAVING
%token HIGH_PRIORITY
%token HOUR_MICROSECOND
%token HOUR_MINUTE
%token HOUR_SECOND
%token IF
%token IGNORE
%token IN
%token INDEX
%token INFILE
%token INNER
%token INOUT
%token INSENSITIVE
%token INSERT
%token INT
%token INTEGER
%token INTERVAL
%token INTO
%token ITERATE
%token JOIN
%token KEY
%token KEYS
%token KILL
%token LEADING
%token LEAVE
%token LEFT
%token LIKE
%token LIMIT
%token LINES
%token LOAD
%token LOCALTIME
%token LOCALTIMESTAMP
%token LOCK
%token LONG
%token LONGBLOB
%token LONGTEXT
%token LOOP
%token LOW_PRIORITY
%token MATCH
%token MEDIUMBLOB
%token MEDIUMINT
%token MEDIUMTEXT
%token MINUTE_MICROSECOND
%token MINUTE_SECOND
%token MOD
%token MODIFIES
%token NATURAL
%token NOT
%token NO_WRITE_TO_BINLOG
%token NULLX
%token NUMBER
%token ON
%token ONDUPLICATE
%token OPTIMIZE
%token OPTION
%token OPTIONALLY
%token OR
%token ORDER
%token OUT
%token OUTER
%token OUTFILE
%token PARTITION
%token PRECISION
%token PRIMARY
%token PROCEDURE
%token PURGE
%token QUICK
%token READ
%token READS
%token REAL
%token REFERENCES
%token REGEXP
%token RELEASE
%token RENAME
%token REPEAT
%token REPLACE
%token REQUIRE
%token RESTRICT
%token RETURN
%token REVOKE
%token RIGHT
%token ROLLUP
%token SCHEMA
%token SCHEMAS
%token SECOND_MICROSECOND
%token SELECT
%token SENSITIVE
%token SEPARATOR
%token SET
%token SHOW
%token SMALLINT
%token SOME
%token SONAME
%token SPATIAL
%token SPECIFIC
%token SQL
%token SQLEXCEPTION
%token SQLSTATE
%token SQLWARNING
%token SQL_BIG_RESULT
%token SQL_CALC_FOUND_ROWS
%token SQL_SMALL_RESULT
%token SSL
%token STARTING
%token STRAIGHT_JOIN
%token TABLE
%token TEMPORARY
%token TEXT
%token TERMINATED
%token THEN
%token TIME
%token TIMESTAMP
%token TINYBLOB
%token TINYINT
%token TINYTEXT
%token TO
%token TRAILING
%token TRIGGER
%token UNDO
%token UNION
%token UNIQUE
%token UNLOCK
%token UNSIGNED
%token UPDATE
%token USAGE
%token USE
%token USING
%token UTC_DATE
%token UTC_TIME
%token UTC_TIMESTAMP
%token VALUES
%token VARBINARY
%token VARCHAR
%token VARYING
%token WHEN
%token WHERE
%token WHILE
%token WITH
%token WRITE
%token XOR
%token YEAR
%token YEAR_MONTH
%token ZEROFILL

 /* functions with special syntax */
%token FSUBSTRING
%token FTRIM
%token FDATE_ADD FDATE_SUB
%token FCOUNT

 /* keywords specific to Calcite SQL dialect */
 /* BEGIN (Calcite SQL keywords) */
%token A
%token ABS
%token ABSENT
%token ABSOLUTE
%token ACTION
%token ADA
%token ADMIN
%token AFTER
%token ALLOCATE
%token ALLOW
%token ALWAYS
%token APPLY
%token ARE
%token ARRAY
%token ARRAY_MAX_CARDINALITY
%token ASENSITIVE
%token ASSERTION
%token ASSIGNMENT
%token ASYMMETRIC
%token AT
%token ATOMIC
%token ATTRIBUTE
%token ATTRIBUTES
%token AUTHORIZATION
%token AVG
/*%token BEGIN /* conflicts with macro BEGIN that bison generates and uses  */
%token BEGIN_FRAME
%token BEGIN_PARTITION
%token BERNOULLI
%token BOOLEAN
%token BREADTH
%token C
%token CALLED
%token CARDINALITY
%token CASCADED
%token CAST
%token CATALOG
%token CATALOG_NAME
%token CEIL
%token CEILING
%token CENTURY
%token CHAIN
%token CHARACTERISTICS
%token CHARACTER_LENGTH
%token CHARACTERS
%token CHARACTER_SET_CATALOG
%token CHARACTER_SET_NAME
%token CHARACTER_SET_SCHEMA
%token CHAR_LENGTH
%token CLASSIFIER
%token CLASS_ORIGIN
%token CLOB
%token CLOSE
%token COALESCE
%token COBOL
%token COLLATION
%token COLLATION_CATALOG
%token COLLATION_NAME
%token COLLATION_SCHEMA
%token COLLECT
%token COLUMN_NAME
%token COMMAND_FUNCTION
%token COMMAND_FUNCTION_CODE
%token COMMIT
%token COMMITTED
%token CONDITIONAL
%token CONDITION_NUMBER
%token CONNECT
%token CONNECTION
%token CONNECTION_NAME
%token CONSTRAINT_CATALOG
%token CONSTRAINT_NAME
%token CONSTRAINTS
%token CONSTRAINT_SCHEMA
%token CONSTRUCTOR
%token CONTAINS
%token CORR
%token CORRESPONDING
%token COUNT
%token COVAR_POP
%token COVAR_SAMP
%token CUBE
%token CUME_DIST
%token CURRENT
%token CURRENT_CATALOG
%token CURRENT_DEFAULT_TRANSFORM_GROUP
%token CURRENT_PATH
%token CURRENT_ROLE
%token CURRENT_ROW
%token CURRENT_SCHEMA
%token CURRENT_TRANSFORM_GROUP_FOR_TYPE
%token CURSOR_NAME
%token CYCLE
%token DATA
%token DATETIME_INTERVAL_CODE
%token DATETIME_INTERVAL_PRECISION
%token DAY
%token DEALLOCATE
%token DECADE
%token DEFAULTS
%token DEFERRABLE
%token DEFERRED
%token DEFINE
%token DEFINED
%token DEFINER
%token DEGREE
%token DENSE_RANK
%token DEPTH
%token DEREF
%token DERIVED
%token DESCRIPTION
%token DESCRIPTOR
%token DIAGNOSTICS
%token DISALLOW
%token DISCONNECT
%token DISPATCH
%token DOMAIN
%token DOW
%token DOY
%token DYNAMIC
%token DYNAMIC_FUNCTION
%token DYNAMIC_FUNCTION_CODE
%token ELEMENT
%token EMPTY
%token ENCODING
%token END-EXEC
%token END_FRAME
%token END_PARTITION
%token EPOCH
%token EQUALS
%token ERROR
%token ESCAPE
%token EVERY
%token EXCEPT
%token EXCEPTION
%token EXCLUDE
%token EXCLUDING
%token EXEC
%token EXECUTE
%token EXP
%token EXTEND
%token EXTERNAL
%token EXTRACT
%token FALSE
%token FILTER
%token FINAL
%token FIRST
%token FIRST_VALUE
%token FLOOR
%token FOLLOWING
%token FORMAT
%token FORTRAN
%token FOUND
%token FRAC_SECOND
%token FRAME_ROW
%token FREE
%token FULL
%token FUNCTION
%token FUSION
%token G
%token GENERAL
%token GENERATED
%token GEOMETRY
%token GET
%token GLOBAL
%token GO
%token GOTO
%token GRANTED
%token GROUPING
%token GROUPS
%token HIERARCHY
%token HOLD
%token HOUR
%token IDENTITY
%token IMMEDIATE
%token IMMEDIATELY
%token IMPLEMENTATION
%token IMPORT
%token INCLUDING
%token INCREMENT
%token INDICATOR
%token INITIAL
%token INITIALLY
%token INPUT
%token INSTANCE
%token INSTANTIABLE
%token INTERSECT
%token INTERSECTION
%token INVOKER
%token ISODOW
%token ISOLATION
%token ISOYEAR
%token JAVA
%token JSON
%token JSON_ARRAY
%token JSON_ARRAYAGG
%token JSON_DEPTH
%token JSON_EXISTS
%token JSON_OBJECT
%token JSON_OBJECTAGG
%token JSON_PRETTY
%token JSON_QUERY
%token JSON_TYPE
%token JSON_VALUE
%token K
%token KEY_MEMBER
%token KEY_TYPE
%token LABEL
%token LAG
%token LANGUAGE
%token LARGE
%token LAST
%token LAST_VALUE
%token LATERAL
%token LEAD
%token LENGTH
%token LEVEL
%token LIBRARY
%token LIKE_REGEX
%token LN
%token LOCAL
%token LOCATOR
%token LOWER
%token M
%token MAP
%token MATCHED
%token MATCHES
%token MATCH_NUMBER
%token MATCH_RECOGNIZE
%token MAX
%token MAXVALUE
%token MEASURES
%token MEMBER
%token MERGE
%token MESSAGE_LENGTH
%token MESSAGE_OCTET_LENGTH
%token MESSAGE_TEXT
%token METHOD
%token MICROSECOND
%token MILLENNIUM
%token MILLISECOND
%token MIN
%token MINUS
%token MINUTE
%token MINVALUE
%token MODULE
%token MONTH
%token MORE
%token MULTISET
%token MUMPS
%token NAMES
%token NANOSECOND
%token NATIONAL
%token NCHAR
%token NCLOB
%token NESTING
%token NEW
%token NEXT
%token NO
%token NONE
%token NORMALIZE
%token NORMALIZED
%token NTH_VALUE
%token NTILE
%token NULLABLE
%token NULLIF
%token NULLS
%token OBJECT
%token OCCURRENCES_REGEX
%token OCTET_LENGTH
%token OCTETS
%token OF
%token OFFSET
%token OLD
%token OMIT
%token ONE
%token ONLY
%token OPEN
%token OPTIONS
%token ORDERING
%token ORDINALITY
%token OTHERS
%token OUTPUT
%token OVER
%token OVERLAPS
%token OVERLAY
%token OVERRIDING
%token PAD
%token PARAMETER
%token PARAMETER_MODE
%token PARAMETER_NAME
%token PARAMETER_ORDINAL_POSITION
%token PARAMETER_SPECIFIC_CATALOG
%token PARAMETER_SPECIFIC_NAME
%token PARAMETER_SPECIFIC_SCHEMA
%token PARTIAL
%token PASCAL
%token PASSING
%token PASSTHROUGH
%token PAST
%token PATH
%token PATTERN
%token PER
%token PERCENT
%token PERCENTILE_CONT
%token PERCENTILE_DISC
%token PERCENT_RANK
%token PERIOD
%token PERMUTE
%token PLACING
%token PLAN
%token PLI
%token PORTION
%token POSITION
%token POSITION_REGEX
%token POWER
%token PRECEDES
%token PRECEDING
%token PREPARE
%token PRESERVE
%token PREV
%token PRIOR
%token PRIVILEGES
%token PUBLIC
%token QUARTER
%token RANGE
%token RANK
%token RECURSIVE
%token REF
%token REFERENCING
%token REGR_AVGX
%token REGR_AVGY
%token REGR_COUNT
%token REGR_INTERCEPT
%token REGR_R2
%token REGR_SLOPE
%token REGR_SXX
%token REGR_SXY
%token REGR_SYY
%token RELATIVE
%token REPEATABLE
%token RESET
%token RESTART
%token RESULT
%token RETURNED_CARDINALITY
%token RETURNED_LENGTH
%token RETURNED_OCTET_LENGTH
%token RETURNED_SQLSTATE
%token RETURNING
%token RETURNS
%token ROLE
%token ROLLBACK
%token ROUTINE
%token ROUTINE_CATALOG
%token ROUTINE_NAME
%token ROUTINE_SCHEMA
%token ROW
%token ROW_COUNT
%token ROW_NUMBER
%token ROWS
%token RUNNING
%token SAVEPOINT
%token SCALAR
%token SCALE
%token SCHEMA_NAME
%token SCOPE
%token SCOPE_CATALOGS
%token SCOPE_NAME
%token SCOPE_SCHEMA
%token SCROLL
%token SEARCH
%token SECOND
%token SECTION
%token SECURITY
%token SEEK
%token SELF
%token SEQUENCE
%token SERIALIZABLE
%token SERVER
%token SERVER_NAME
%token SESSION
%token SESSION_USER
%token SETS
%token SIMILAR
%token SIMPLE
%token SIZE
%token SKIP
%token SOURCE
%token SPACE
%token SPECIFIC_NAME
%token SPECIFICTYPE
%token SQL_BIGINT
%token SQL_BINARY
%token SQL_BIT
%token SQL_BLOB
%token SQL_BOOLEAN
%token SQL_CHAR
%token SQL_CLOB
%token SQL_DATE
%token SQL_DECIMAL
%token SQL_DOUBLE
%token SQL_FLOAT
%token SQL_INTEGER
%token SQL_INTERVAL_DAY
%token SQL_INTERVAL_DAY_TO_HOUR
%token SQL_INTERVAL_DAY_TO_MINUTE
%token SQL_INTERVAL_DAY_TO_SECOND
%token SQL_INTERVAL_HOUR
%token SQL_INTERVAL_HOUR_TO_MINUTE
%token SQL_INTERVAL_HOUR_TO_SECOND
%token SQL_INTERVAL_MINUTE
%token SQL_INTERVAL_MINUTE_TO_SECOND
%token SQL_INTERVAL_MONTH
%token SQL_INTERVAL_SECOND
%token SQL_INTERVAL_YEAR
%token SQL_INTERVAL_YEAR_TO_MONTH
%token SQL_LONGVARBINARY
%token SQL_LONGVARCHAR
%token SQL_LONGVARNCHAR
%token SQL_NCHAR
%token SQL_NCLOB
%token SQL_NUMERIC
%token SQL_NVARCHAR
%token SQL_REAL
%token SQL_SMALLINT
%token SQL_TIME
%token SQL_TIMESTAMP
%token SQL_TINYINT
%token SQL_TSI_DAY
%token SQL_TSI_FRAC_SECOND
%token SQL_TSI_HOUR
%token SQL_TSI_MICROSECOND
%token SQL_TSI_MINUTE
%token SQL_TSI_MONTH
%token SQL_TSI_QUARTER
%token SQL_TSI_SECOND
%token SQL_TSI_WEEK
%token SQL_TSI_YEAR
%token SQL_VARBINARY
%token SQL_VARCHAR
%token SQRT
%token START
%token STATE
%token STATEMENT
%token STATIC
%token STDDEV_POP
%token STDDEV_SAMP
%token STREAM
%token STRUCTURE
%token STYLE
%token SUBCLASS_ORIGIN
%token SUBMULTISET
%token SUBSET
%token SUBSTITUTE
%token SUBSTRING
%token SUBSTRING_REGEX
%token SUCCEEDS
%token SUM
%token SYMMETRIC
%token SYSTEM
%token SYSTEM_TIME
%token SYSTEM_USER
%token TABLE_NAME
%token TABLESAMPLE
%token TIES
%token TIMESTAMPADD
%token TIMESTAMPDIFF
%token TIMEZONE_HOUR
%token TIMEZONE_MINUTE
%token TOP_LEVEL_COUNT
%token TRANSACTION
%token TRANSACTIONS_ACTIVE
%token TRANSACTIONS_COMMITTED
%token TRANSACTIONS_ROLLED_BACK
%token TRANSFORM
%token TRANSFORMS
%token TRANSLATE
%token TRANSLATE_REGEX
%token TRANSLATION
%token TREAT
%token TRIGGER_CATALOG
%token TRIGGER_NAME
%token TRIGGER_SCHEMA
%token TRIM
%token TRIM_ARRAY
%token TRUE
%token TRUNCATE
%token TYPE
%token UESCAPE
%token UNBOUNDED
%token UNCOMMITTED
%token UNCONDITIONAL
%token UNDER
%token UNKNOWN
%token UNNAMED
%token UNNEST
%token UPPER
%token UPSERT
%token USER
%token USER_DEFINED_TYPE_CATALOG
%token USER_DEFINED_TYPE_CODE
%token USER_DEFINED_TYPE_NAME
%token USER_DEFINED_TYPE_SCHEMA
%token UTF16
%token UTF32
%token UTF8
%token VALUE_OF
%token VAR_POP
%token VAR_SAMP
%token VDS
%token VERSION
%token VERSIONING
%token VIEW
%token WEEK
%token WHENEVER
%token WIDTH_BUCKET
%token WINDOW
%token WITHIN
%token WITHOUT
%token WORK
%token WRAPPER
%token XML
%token ZONE
 /* END   (Calcite SQL keywords) */

%type <intval> select_opts select_expr_list
%type <intval> val_list opt_val_list case_list
%type <intval> groupby_list opt_with_rollup opt_asc_desc orderby_list
%type <intval> table_references opt_inner_cross opt_outer
%type <intval> left_or_right opt_left_or_right_outer column_list
%type <intval> index_list opt_for_join

%type <intval> delete_opts delete_list
%type <intval> insert_opts insert_vals insert_vals_list
%type <intval> insert_asgn_list opt_if_not_exists update_opts update_asgn_list
%type <intval> opt_temporary opt_length opt_binary opt_uz enum_list
%type <intval> column_atts data_type opt_ignore_replace create_col_list
%type <strval> field_name in_set_name
%type <intval> numeric_expr interval_exp numeric_or_interval_expr
%type <intval> PARTITION opt_partition_expr opt_partition
%type <intval> opt_partition_range opt_partition_rows opt_positioning
%type <intval> opt_partition_spec opt_partition_full_spec
%type <intval> with_item_list with_item
%type <intval> with_name with_name_list values_expr_list all_or_distinct
%type <intval> solitary_semi_colon

%start stmt_list

%{
void yyerror(char *s, ...);
void lyyerror(YYLTYPE, char *s, ...);
void emit(char *s, ...);
 %}
  /* free discarded tokens */
%destructor { printf ("free at %d %s\n",@$.first_line, $$); free($$); } <strval>

%%

stmt_list:
    stmt ';'
  | stmt_list stmt ';'
  ;

stmt_list:
     error ';'
   | stmt_list error ';' ;

   /* statements: query statement */

stmt: query { emit("STMT"); } ;

stmt: query_into { emit("STMT"); } ;

query:
      values_expr_list
    | with_stmt
    | net_result_set
    ;

query_into: query opt_into_list ;

net_result_set: result_set result_set_filtering_opts ;

result_set:
      select_stmt
    | query_sets_op_result_stmt
    ;

values_expr_list:
      select_expr                      { $$ = 1; }
    | values_expr_list ',' select_expr { $$ = $1 + 1; }
    ;

with_stmt:
      WITH with_item_list       { emit("WITH %d", $2); }
    | WITH with_item_list query { emit("WITH %d", $2); }
    ;

with_item_list:
      with_item                     { $$ = 1; }
    | with_item_list ',' with_item  { $$ = $1 + 1; }
    ;

with_item:
      with_name
    | with_name AS '(' query ')'
    | '(' with_name_list ')'      { $$ = $2; }
    ;

with_name_list:
      with_name
    | with_name_list ',' with_name  { $$ = $1 + 1; }
    ;

with_name:
      NAME        { emit("WITH_NAME %s", $1); free($1); $$ = 1; }
    | field_name  { emit("WITH_DOT_NAME %s", $1); free($1); $$ = 1; }
    ;

query_sets_op_result_stmt:
      query UNION     all_or_distinct query { emit("UNION_SETS %d", $3); }
    | query EXCEPT    all_or_distinct query { emit("EXCEPT_SETS %d", $3); }
    | query MINUS     all_or_distinct query { emit("MINUS_SETS %d", $3); }
    | query INTERSECT all_or_distinct query { emit("INTERSECT_SETS %d", $3); }
    ;

all_or_distinct: /* nil */  { $$ = 0; }
    | ALL                   { $$ = 0; }
    | DISTINCT              { $$ = 1; }
    ;

   /* statements: select statement */

select_stmt:
      SELECT select_opts select_expr_list     { emit("SELECT_NO_DATA %d %d", $2, $3); }
    | SELECT select_opts select_expr_list
             FROM table_references
             opt_where opt_groupby opt_having { emit("SELECT %d %d %d", $2, $3, $5); }
    | SELECT select_opts select_expr_list
             OVER '(' opt_partition_full_spec ')'
             FROM table_references
             opt_where opt_groupby opt_having { emit("SELECT_OVER %d %d %d %d", $2, $3, $6, $9); }
    ;

result_set_filtering_opts: opt_orderby opt_limit ;

opt_where: /* nil */ 
   | WHERE expr { emit("WHERE"); }
   ;

opt_groupby: /* nil */ 
   | GROUP BY groupby_list opt_with_rollup { emit("GROUP_BY_LIST %d %d", $3, $4); }
   ;

groupby_list:
     expr opt_asc_desc                  { emit("GROUP_BY %d",  $2); $$ = 1; }
   | groupby_list ',' expr opt_asc_desc { emit("GROUP_BY %d",  $4); $$ = $1 + 1; }
   ;

opt_asc_desc: /* nil */ { $$ = 0; }
   | ASC                { $$ = 0; }
   | DESC               { $$ = 1; }
   ;

opt_with_rollup: /* nil */  { $$ = 0; }
   | WITH ROLLUP            { $$ = 1; }
   ;

opt_having: /* nil */
   | HAVING expr { emit("HAVING"); }
   ;

opt_orderby: /* nil */ %prec NIL
   | ORDER BY orderby_list { emit("ORDER_BY_LIST %d", $3); }
   ;

orderby_list:
     expr opt_asc_desc                  { emit("ORDER_BY %d",  $2); $$ = 1; }
   | orderby_list ',' expr opt_asc_desc { emit("ORDER_BY %d",  $4); $$ = $1 + 1; }
   ;

opt_limit: /* nil */ %prec NIL
   | LIMIT expr          { emit("LIMIT 1"); }
   | LIMIT expr ',' expr { emit("LIMIT 2"); }
   ; 

opt_into_list: INTO column_list { emit("INTO %d", $2); } ;

column_list:
    field_name                  { emit("COLUMN %s", $1); free($1); $$ = 1; }
  | STRING                      { lyyerror(@1, "string '%s' found where name required", $1);
                                  emit("COLUMN %s", $1); free($1); $$ = 1; }
  | column_list ',' field_name  { emit("COLUMN %s", $3); free($3); $$ = $1 + 1; }
  | column_list ',' STRING      { lyyerror(@3, "string '%s' found where name required", $1);
                                  emit("COLUMN %s", $3); free($3); $$ = $1 + 1; }
  ;

select_opts:                          { $$ = 0; }
    | select_opts ALL                 { if($$ & 01)   lyyerror(@2,"duplicate ALL option"); $$ = $1 | 01; }
    | select_opts DISTINCT            { if($$ & 02)   lyyerror(@2,"duplicate DISTINCT option"); $$ = $1 | 02; }
    | select_opts DISTINCTROW         { if($$ & 04)   lyyerror(@2,"duplicate DISTINCTROW option"); $$ = $1 | 04; }
    | select_opts HIGH_PRIORITY       { if($$ & 010)  lyyerror(@2,"duplicate HIGH_PRIORITY option"); $$ = $1 | 010; }
    | select_opts STRAIGHT_JOIN       { if($$ & 020)  lyyerror(@2,"duplicate STRAIGHT_JOIN option"); $$ = $1 | 020; }
    | select_opts SQL_SMALL_RESULT    { if($$ & 040)  lyyerror(@2,"duplicate SQL_SMALL_RESULT option"); $$ = $1 | 040; }
    | select_opts SQL_BIG_RESULT      { if($$ & 0100) lyyerror(@2,"duplicate SQL_BIG_RESULT option"); $$ = $1 | 0100; }
    | select_opts SQL_CALC_FOUND_ROWS { if($$ & 0200) lyyerror(@2,"duplicate SQL_CALC_FOUND_ROWS option"); $$ = $1 | 0200; }
    ;

select_expr_list:
      select_expr                      { $$ = 1; }
    | select_expr_list ',' select_expr { $$ = $1 + 1; }
    | '*'                              { emit("SELECT_ALL_IMPLICIT"); $$ = 1; }
    ;

select_expr:
		  NAME '.' '*'			{ emit("SELECT_ALL_FROM %s", $1); free($1); }
    | expr opt_as_alias
    ;

table_references:
      table_reference                       { $$ = 1; }
    | table_references ',' table_reference  { $$ = $1 + 1; }
    ;

table_reference:
      table_factor
    | join_table
    ;

field_name:
      NAME '.' NAME        { $$ = concat_strings($1, ".", $3); free($1); free($3); }
    | field_name  '.' NAME { $$ = concat_strings($1, ".", $3); free($1); free($3); }
    ;

table_factor:
      NAME opt_as_alias index_hint        { emit("TABLE %s", $1); free($1); }
    | field_name opt_as_alias index_hint  { emit("TABLE %s", $1); free($1); }
    | table_subquery                      { emit("SUBQUERY_ANON"); }
    | table_subquery opt_as NAME          { emit("SUBQUERY_AS %s", $3); free($3); }
    | '(' table_references ')'            { emit("TABLE_REFERENCES %d", $2); }
    ;

opt_as:
      AS 
    | /* nil */
    ;

opt_as_alias:
      AS NAME { emit ("ALIAS_AS %s", $2); free($2); }
    | NAME    { emit ("ALIAS_AS %s", $1); free($1); }
    | /* nil */
    ;

join_table:
      table_reference opt_inner_cross JOIN table_factor opt_join_condition
      { emit("JOIN %d", 0100+$2); }
    | table_reference STRAIGHT_JOIN table_factor
      { emit("JOIN %d", 0200); }
    | table_reference STRAIGHT_JOIN table_factor ON expr
      { emit("JOIN %d", 0200); }
    | table_reference left_or_right opt_outer JOIN table_factor join_condition
      { emit("JOIN %d", 0300+$2+$3); }
    | table_reference NATURAL opt_left_or_right_outer JOIN table_factor
      { emit("JOIN %d", 0400+$3); }
    ;

opt_inner_cross: /* nil */  { $$ = 0; }
    | INNER                 { $$ = 1; }
    | CROSS                 { $$ = 2; }
    ;

opt_outer: /* nil */  { $$ = 0; }
    | OUTER           { $$ = 4; }
    ;

left_or_right:
      LEFT  { $$ = 1; }
    | RIGHT { $$ = 2; }
    ;

opt_left_or_right_outer:
      LEFT opt_outer  { $$ = 1 + $2; }
    | RIGHT opt_outer { $$ = 2 + $2; }
    | /* nil */       { $$ = 0; }
    ;

opt_join_condition: join_condition | /* nil */ ;

join_condition:
      ON expr                   { emit("ON_EXPR"); }
    | USING '(' column_list ')' { emit("USING %d", $3); }
    ;

index_hint:
      USE KEY opt_for_join '(' index_list ')'
      { emit("INDEX_HINT %d %d", $5, 010+$3); }
    | IGNORE KEY opt_for_join '(' index_list ')'
      { emit("INDEX_HINT %d %d", $5, 020+$3); }
    | FORCE KEY opt_for_join '(' index_list ')'
      { emit("INDEX_HINT %d %d", $5, 030+$3); }
    | /* nil */
    ;

opt_for_join:
      FOR JOIN  { $$ = 1; }
    | /* nil */ { $$ = 0; }
    ;

index_list:
      NAME                { emit("INDEX %s", $1); free($1); $$ = 1; }
    | index_list ',' NAME { emit("INDEX %s", $3); free($3); $$ = $1 + 1; }
    ;

table_subquery: '(' select_stmt ')' { emit("SUBQUERY"); }
    ;

   /* statements: delete statement */

stmt: delete_stmt { emit("STMT"); } ;

delete_stmt:
      DELETE delete_opts FROM NAME opt_where opt_orderby opt_limit
      { emit("DELETE_ONE %d %s", $2, $4); free($4); }
    ;

delete_opts:
      delete_opts LOW_PRIORITY { $$ = $1 + 01; }
    | delete_opts QUICK        { $$ = $1 + 02; }
    | delete_opts IGNORE       { $$ = $1 + 04; }
    | /* nil */                { $$ = 0; }
    ;

delete_stmt:
      DELETE delete_opts delete_list FROM table_references opt_where
      { emit("DELETE_MULTI %d %d %d", $2, $3, $5); }
    ;

delete_list:
      NAME opt_dot_star                 { emit("TABLE %s", $1); free($1); $$ = 1; }
    | delete_list ',' NAME opt_dot_star { emit("TABLE %s", $3); free($3); $$ = $1 + 1; }
    ;

opt_dot_star: /* nil */
    | '.' '*'
    ;

delete_stmt:
      DELETE delete_opts FROM delete_list USING table_references opt_where
      { emit("DELETE_MULTI %d %d %d", $2, $4, $6); }
    ;

   /* statements: insert statement */

stmt: insert_stmt { emit("STMT"); }
   ;

insert_stmt:
     INSERT insert_opts opt_into NAME opt_col_names VALUES insert_vals_list opt_ondupupdate
                     { emit("INSERT_VALS %d %d %s", $2, $7, $4); free($4); }
   ;

opt_ondupupdate: /* nil */
   | ONDUPLICATE KEY UPDATE insert_asgn_list { emit("DUP_UPDATE %d", $4); }
   ;

insert_opts: /* nil */         { $$ = 0; }
   | insert_opts LOW_PRIORITY  { $$ = $1 | 01 ; }
   | insert_opts DELAYED       { $$ = $1 | 02 ; }
   | insert_opts HIGH_PRIORITY { $$ = $1 | 04 ; }
   | insert_opts IGNORE        { $$ = $1 | 010 ; }
   ;

opt_into: INTO | /* nil */
   ;

opt_col_names: /* nil */
   | '(' column_list ')' { emit("INSERT_COLS %d", $2); }
   ;

insert_vals_list: '(' insert_vals ')' { emit("VALUES %d", $2); $$ = 1; }
   | insert_vals_list ',' '(' insert_vals ')' { emit("VALUES %d", $4); $$ = $1 + 1; }

insert_vals:
     expr { $$ = 1; }
   | DEFAULT { emit("DEFAULT"); $$ = 1; }
   | insert_vals ',' expr { $$ = $1 + 1; }
   | insert_vals ',' DEFAULT { emit("DEFAULT"); $$ = $1 + 1; }
   ;

insert_stmt: INSERT insert_opts opt_into NAME
    SET insert_asgn_list
    opt_ondupupdate
     { emit("INSERT_ASGN %d %d %s", $2, $6, $4); free($4); }
   ;

insert_stmt: INSERT insert_opts opt_into NAME opt_col_names
    select_stmt
    opt_ondupupdate { emit("INSERT_SELECT %d %s", $2, $4); free($4); }
  ;

insert_asgn_list:
     NAME COMPARISON expr 
       { if ($2 != 4) { lyyerror(@2,"bad insert assignment to %s", $1); YYERROR; }
       emit("ASSIGN %s", $1); free($1); $$ = 1; }
   | NAME COMPARISON DEFAULT
       { if ($2 != 4) { lyyerror(@2,"bad insert assignment to %s", $1); YYERROR; }
                 emit("DEFAULT"); emit("ASSIGN %s", $1); free($1); $$ = 1; }
   | insert_asgn_list ',' NAME COMPARISON expr
       { if ($4 != 4) { lyyerror(@4,"bad insert assignment to %s", $1); YYERROR; }
                 emit("ASSIGN %s", $3); free($3); $$ = $1 + 1; }
   | insert_asgn_list ',' NAME COMPARISON DEFAULT
       { if ($4 != 4) { lyyerror(@4,"bad insert assignment to %s", $1); YYERROR; }
                 emit("DEFAULT"); emit("ASSIGN %s", $3); free($3); $$ = $1 + 1; }
   ;

   /** replace just like insert **/
stmt: replace_stmt { emit("STMT"); }
   ;

replace_stmt: REPLACE insert_opts opt_into NAME
     opt_col_names
     VALUES insert_vals_list
     opt_ondupupdate { emit("REPLACE_VALS %d %d %s", $2, $7, $4); free($4); }
   ;

replace_stmt: REPLACE insert_opts opt_into NAME
    SET insert_asgn_list
    opt_ondupupdate
     { emit("REPLACE_ASGN %d %d %s", $2, $6, $4); free($4); }
   ;

replace_stmt: REPLACE insert_opts opt_into NAME opt_col_names
    select_stmt
    opt_ondupupdate { emit("REPLACE_SELECT %d %s", $2, $4); free($4); }
  ;

/** update **/
stmt: update_stmt { emit("STMT"); }
   ;

update_stmt: UPDATE update_opts table_references
    SET update_asgn_list
    opt_where
    opt_orderby
opt_limit { emit("UPDATE %d %d %d", $2, $3, $5); }
;

update_opts: /* nil */ { $$ = 0; }
   | insert_opts LOW_PRIORITY { $$ = $1 | 01 ; }
   | insert_opts IGNORE { $$ = $1 | 010 ; }
   ;

update_asgn_list:
     NAME COMPARISON expr 
     { if ($2 != 4) { lyyerror(@2,"bad update assignment to %s", $1); YYERROR; }
   emit("ASSIGN %s", $1); free($1); $$ = 1; }
   | field_name COMPARISON expr 
   { if ($2 != 4) { lyyerror(@2,"bad update assignment to %s", $1); YYERROR; }
   emit("ASSIGN %s", $1); free($1); $$ = 1; }
   | update_asgn_list ',' NAME COMPARISON expr
   { if ($4 != 4) { lyyerror(@4,"bad update assignment to %s", $3); YYERROR; }
   emit("ASSIGN %s.%s", $3); free($3); $$ = $1 + 1; }
   | update_asgn_list ',' field_name COMPARISON expr
   { if ($4 != 4) { lyyerror(@4,"bad update  assignment to %s", $3); YYERROR; }
   emit("ASSIGN %s", $3); free($3); $$ = 1; }
   ;


   /** create database **/

stmt: create_database_stmt { emit("STMT"); }
   ;

create_database_stmt: 
     CREATE DATABASE opt_if_not_exists NAME { emit("CREATE_DATABASE %d %s", $3, $4); free($4); }
   | CREATE SCHEMA   opt_if_not_exists NAME { emit("CREATE_SCHEMA %d %s", $3, $4); free($4); }
   ;

opt_if_not_exists:  /* nil */ { $$ = 0; }
   | IF EXISTS        { if(!$2) { lyyerror(@2,"IF EXISTS doesn't exist"); YYERROR; }
                        $$ = $2; /* NOT EXISTS hack */ }
   ;


   /** create table **/
stmt: create_table_stmt { emit("STMT"); } ;

create_table_stmt:
      CREATE opt_temporary TABLE opt_if_not_exists NAME '(' create_col_list ')'
      { emit("CREATE_TABLE %d %d %d %s", $2, $4, $7, $5); free($5); }
    ;

create_table_stmt:
      CREATE opt_temporary TABLE opt_if_not_exists field_name '(' create_col_list ')'
      { emit("CREATE_TABLE %d %d %d %s", $2, $4, $7, $5); free($5); }
    ;

create_table_stmt:
      CREATE opt_temporary TABLE opt_if_not_exists NAME '(' create_col_list ')'
      create_select_statement
      { emit("CREATE_TABLE %d %d %d %s", $2, $4, $7, $5); free($5); }
    ;

create_table_stmt:
      CREATE opt_temporary TABLE opt_if_not_exists NAME create_select_statement
      { emit("CREATE_TABLE %d %d 0 %s", $2, $4, $5); free($5); }
    ;

create_table_stmt:
      CREATE opt_temporary TABLE opt_if_not_exists field_name '(' create_col_list ')'
      create_select_statement
      { emit("CREATE_TABLE %d %d 0 %s", $2, $4, $7, $5); free($5); }
    ;

create_table_stmt:
      CREATE opt_temporary TABLE opt_if_not_exists field_name create_select_statement
      { emit("CREATE_TABLE %d %d 0 %s", $2, $4, $5); free($5); }
    ;

   /** create vds **/
stmt: create_vds_stmt { emit("STMT"); } ;

create_vds_stmt:
      CREATE opt_temporary VDS opt_if_not_exists field_name create_select_statement
      { emit("CREATE_VDS %d %d 0 %s", $2, $4, $5); free($5); }
    ;

create_col_list:
      create_definition                     { $$ = 1; }
    | create_col_list ',' create_definition { $$ = $1 + 1; }
    ;

create_definition: { emit("START_COL"); } NAME data_type column_atts
                   { emit("COLUMN_DEF %d %s", $3, $2); free($2); }

    | PRIMARY KEY '(' column_list ')'    { emit("PRI_KEY %d", $4); }
    | KEY '(' column_list ')'            { emit("KEY %d", $3); }
    | INDEX '(' column_list ')'          { emit("KEY %d", $3); }
    | FULLTEXT INDEX '(' column_list ')' { emit("TEXT_INDEX %d", $4); }
    | FULLTEXT KEY '(' column_list ')'   { emit("TEXT_INDEX %d", $4); }
    ;

column_atts: /* nil */ { $$ = 0; }
    | column_atts NOT NULLX             { emit("ATTR NOT_NULL"); $$ = $1 + 1; }
    | column_atts NULLX
    | column_atts DEFAULT STRING        { emit("ATTR DEFAULT STRING %s", $3); free($3); $$ = $1 + 1; }
    | column_atts DEFAULT INTNUM        { emit("ATTR DEFAULT NUMBER %d", $3); $$ = $1 + 1; }
    | column_atts DEFAULT APPROXNUM     { emit("ATTR DEFAULT FLOAT %g", $3); $$ = $1 + 1; }
    | column_atts DEFAULT BOOL          { emit("ATTR DEFAULT BOOL %d", $3); $$ = $1 + 1; }
    | column_atts AUTO_INCREMENT        { emit("ATTR AUTO_INC"); $$ = $1 + 1; }
    | column_atts UNIQUE '(' column_list ')' { emit("ATTR UNIQUE_KEY %d", $4); $$ = $1 + 1; }
    | column_atts UNIQUE KEY { emit("ATTR UNIQUE_KEY"); $$ = $1 + 1; }
    | column_atts PRIMARY KEY { emit("ATTR PRI_KEY"); $$ = $1 + 1; }
    | column_atts KEY { emit("ATTR PRI_KEY"); $$ = $1 + 1; }
    | column_atts COMMENT STRING { emit("ATTR COMMENT %s", $3); free($3); $$ = $1 + 1; }
    ;

opt_length: /* nil */           { $$ = 0; }
   | '(' INTNUM ')'             { $$ = $2; }
   | '(' INTNUM ',' INTNUM ')'  { $$ = $2 + 1000*$4; }
   ;

opt_binary: /* nil */ { $$ = 0; }
   | BINARY           { $$ = 4000; }
   ;

opt_uz: /* nil */     { $$ = 0; }
   | opt_uz UNSIGNED  { $$ = $1 | 1000; }
   | opt_uz ZEROFILL  { $$ = $1 | 2000; }
   ;

opt_csc: /* nil */
   | opt_csc CHAR SET STRING { emit("COL_CHARSET %s", $4); free($4); }
   | opt_csc COLLATE STRING  { emit("COL_COLLATE %s", $3); free($3); }
   ;

data_type:
     BIT opt_length { $$ = 10000 + $2; }
   | TINYINT opt_length opt_uz { $$ = 10000 + $2; }
   | SMALLINT opt_length opt_uz { $$ = 20000 + $2 + $3; }
   | MEDIUMINT opt_length opt_uz { $$ = 30000 + $2 + $3; }
   | INT opt_length opt_uz { $$ = 40000 + $2 + $3; }
   | INTEGER opt_length opt_uz { $$ = 50000 + $2 + $3; }
   | BIGINT opt_length opt_uz { $$ = 60000 + $2 + $3; }
   | REAL opt_length opt_uz { $$ = 70000 + $2 + $3; }
   | DOUBLE opt_length opt_uz { $$ = 80000 + $2 + $3; }
   | FLOAT opt_length opt_uz { $$ = 90000 + $2 + $3; }
   | DECIMAL opt_length opt_uz { $$ = 110000 + $2 + $3; }
   | DATE { $$ = 100001; }
   | TIME { $$ = 100002; }
   | TIMESTAMP { $$ = 100003; }
   | DATETIME { $$ = 100004; }
   | YEAR { $$ = 100005; }
   | CHAR opt_length opt_csc { $$ = 120000 + $2; }
   | VARCHAR opt_csc { $$ = 130000 + 32; } /* defaulting VARCHAR to size 32 characters */
   | VARCHAR '(' INTNUM ')' opt_csc { $$ = 130000 + $3; }
   | BINARY opt_length { $$ = 140000 + $2; }
   | VARBINARY '(' INTNUM ')' { $$ = 150000 + $3; }
   | TINYBLOB { $$ = 160001; }
   | BLOB { $$ = 160002; }
   | MEDIUMBLOB { $$ = 160003; }
   | LONGBLOB { $$ = 160004; }
   | TINYTEXT opt_binary opt_csc { $$ = 170000 + $2; }
   | TEXT opt_binary opt_csc { $$ = 171000 + $2; }
   | MEDIUMTEXT opt_binary opt_csc { $$ = 172000 + $2; }
   | LONGTEXT opt_binary opt_csc { $$ = 173000 + $2; }
   | ENUM '(' enum_list ')' opt_csc { $$ = 200000 + $3; }
   | SET '(' enum_list ')' opt_csc { $$ = 210000 + $3; }
   ;

enum_list:
     STRING               { emit("ENUM_VAL %s", $1); free($1); $$ = 1; }
   | enum_list ',' STRING { emit("ENUM_VAL %s", $3); free($3); $$ = $1 + 1; }
   ;

create_select_statement: opt_ignore_replace AS query { emit("CREATE_SELECT %d", $1); } ;

opt_ignore_replace: /* nil */ { $$ = 0; }
   | IGNORE                   { $$ = 1; }
   | REPLACE                  { $$ = 2; }
   ;

opt_temporary: /* nil */  { $$ = 0; }
   | TEMPORARY            { $$ = 1;}
   ;

   /**** set user variables ****/

stmt: set_stmt { emit("STMT"); } ;

set_stmt: SET set_list ;

set_list: set_expr | set_list ',' set_expr ;

set_expr:
      USERVAR COMPARISON expr { if ($2 != 4) { lyyerror(@2,"bad set to @%s", $1); YYERROR; }
                                emit("SET %s", $1); free($1); }
    | USERVAR ASSIGN expr     { emit("SET %s", $1); free($1); }
    ;

   /**** expressions ****/

expr: '(' expr ')' ; /* valid expressions can be appear inside parenthesis */

expr:
     NAME       { emit("NAME %s", $1); free($1); }
   | USERVAR    { emit("USER_VAR %s", $1); free($1); }
   | field_name { emit("FIELD_NAME %s", $1); free($1); }
   | STRING     { emit("STRING %s", $1); free($1); }
   | INTNUM     { emit("NUMBER %d", $1); }
   | APPROXNUM  { emit("FLOAT %g", $1); }
   | BOOL       { emit("BOOL %d", $1); }
   ;

numeric_expr:
     expr '+' expr { emit("ADD"); }
   | expr '-' expr { emit("SUB"); }
   | expr '*' expr { emit("MUL"); }
   | expr '/' expr { emit("DIV"); }
   | expr '%' expr { emit("MOD"); }
   | expr MOD expr { emit("MOD"); }
   | '-' expr %prec UMINUS { emit("NEG"); }
   | expr ANDOP expr { emit("AND"); }
   | expr OR expr { emit("OR"); }
   | expr XOR expr { emit("XOR"); }
   | expr COMPARISON expr { emit("CMP %d", $2); }
   | expr COMPARISON '(' select_stmt ')' { emit("CMP_SELECT %d", $2); }
   | expr COMPARISON ANY '(' select_stmt ')' { emit("CMP_ANY_SELECT %d", $2); }
   | expr COMPARISON SOME '(' select_stmt ')' { emit("CMP_ANY_SELECT %d", $2); }
   | expr COMPARISON ALL '(' select_stmt ')' { emit("CMP_ALL_SELECT %d", $2); }
   | expr '|' expr { emit("BIT_OR"); }
   | expr '&' expr { emit("BIT_AND"); }
   | expr '^' expr { emit("BIT_XOR"); }
   | expr SHIFT expr { emit("SHIFT %s", $2==1?"left":"right"); }
   | NOT expr { emit("NOT"); }
   | '!' expr { emit("NOT"); }
   | USERVAR ASSIGN expr { emit("ASSIGN @%s", $1); free($1); }
   ;    

expr: numeric_expr;

expr:
     expr IS NULLX     { emit("IS_NULL"); }
   | expr IS NOT NULLX { emit("IS_NULL"); emit("NOT"); }
   | expr IS BOOL      { emit("IS_BOOL %d", $3); }
   | expr IS NOT BOOL  { emit("IS_BOOL %d", $4); emit("NOT"); }
   ;

expr: expr BETWEEN expr AND expr %prec BETWEEN { emit("BETWEEN"); } ;

val_list:
     expr              { $$ = 1; }
   | expr ',' val_list { $$ = 1 + $3; }
   ;

opt_val_list: /* nil */ { $$ = 0; }
   | val_list
   ;

expr:
     expr IN     in_set_name         { emit("IS_IN_SET_NAME %s", $3); free($3); }
   | expr NOT IN in_set_name         { emit("IS_IN_SET_NAME %s", $4); emit("NOT"); free($4); }
   | expr IN     str_expr            { emit("IS_IN_SET_STRTOK"); }
   | expr NOT IN str_expr            { emit("IS_IN_SET_STRTOK"); emit("NOT"); }
   | expr IN     '(' val_list ')'    { emit("IS_IN %d", $4); }
   | expr NOT IN '(' val_list ')'    { emit("IS_IN %d", $5); emit("NOT"); }
   | expr IN     '(' select_stmt ')' { emit("IS_IN_SELECT"); }
   | expr NOT IN '(' select_stmt ')' { emit("IS_IN_SELECT"); emit("NOT"); }
   | EXISTS      '(' select_stmt ')' { emit("EXISTS"); if($1)emit("NOT"); }
   ;

in_set_name:
     NAME
   | field_name
   ;

str_expr:
     STRING            { emit("STRING %s", $1); free($1); }
   | fstr_expr
   | general_func_call
   ;

expr: general_func_call ;

general_func_call: NAME '(' opt_val_list ')' {  emit("CALL %d %s", $3, $1); free($1); } ;

  /* functions with special syntax */
expr:
     CAST '(' NULLX AS data_type ')'       { emit("CAST_AS %d NULL", $5); }
   | CAST '(' NAME AS data_type ')'        { emit("CAST_AS %d %s", $5, $3); free($3); }
   | CAST '(' field_name AS data_type ')'  { emit("CAST_AS %d %s", $5, $3); free($3); }
   ;

expr:
     FCOUNT '(' '*' ')'  { emit("COUNT_ALL"); }
   | FCOUNT '(' expr ')' { emit(" CALL 1 COUNT"); } 
   ;

expr: fstr_expr ;

fstr_expr:
     FSUBSTRING '(' val_list ')'                { emit("CALL %d SUBSTR", $3);}
   | FSUBSTRING '(' expr FROM expr ')'          { emit("CALL 2 SUBSTR"); }
   | FSUBSTRING '(' expr FROM expr FOR expr ')' { emit("CALL 3 SUBSTR"); }
   | FTRIM '(' val_list ')'                     { emit("CALL %d TRIM", $3); }
   | FTRIM '(' trim_ltb expr FROM val_list ')'  { emit("CALL 3 TRIM"); }
   ;

trim_ltb:
     LEADING  { emit("INT 1"); }
   | TRAILING { emit("INT 2"); }
   | BOTH     { emit("INT 3"); }
   ;

expr: FDATE_ADD '(' expr ',' interval_exp ')' { emit("CALL 3 DATE_ADD"); }
   |  FDATE_SUB '(' expr ',' interval_exp ')' { emit("CALL 3 DATE_SUB"); }
   ;

expr: interval_exp ;

interval_exp:
     INTERVAL expr DAY              { emit("INTERVAL 1"); }
   | INTERVAL expr DAY_HOUR         { emit("INTERVAL 2"); }
   | INTERVAL expr DAY_MICROSECOND  { emit("INTERVAL 3"); }
   | INTERVAL expr DAY_MINUTE       { emit("INTERVAL 4"); }
   | INTERVAL expr DAY_SECOND       { emit("INTERVAL 5"); }
   | INTERVAL expr MONTH            { emit("INTERVAL 6"); }
   | INTERVAL expr YEAR_MONTH       { emit("INTERVAL 7"); }
   | INTERVAL expr YEAR             { emit("INTERVAL 8"); }
   | INTERVAL expr HOUR_MICROSECOND { emit("INTERVAL 9"); }
   | INTERVAL expr HOUR_MINUTE      { emit("INTERVAL 10"); }
   | INTERVAL expr HOUR_SECOND      { emit("INTERVAL 11"); }
   ;

expr:
     CASE expr case_list END                      { emit("CASE_VAL %d 0", $3); }
   | CASE expr case_list ELSE nullable_expr END   { emit("CASE_VAL %d 1", $3); }
   | CASE case_list END                           { emit("CASE %d 0", $2); }
   | CASE case_list ELSE nullable_expr END        { emit("CASE %d 1", $2); }
   ;

case_list:
     WHEN expr THEN nullable_expr           { $$ = 1; }
   | case_list WHEN expr THEN nullable_expr { $$ = $1+1; } 
   ;

nullable_expr:
     NULLX
   | expr
   ;

expr:
     expr LIKE expr     { emit("LIKE"); }
   | expr NOT LIKE expr { emit("LIKE"); emit("NOT"); }
   ;

expr:
     expr REGEXP expr     { emit("REGEXP"); }
   | expr NOT REGEXP expr { emit("REGEXP"); emit("NOT"); }
   ;

expr:
     CURRENT_TIMESTAMP  { emit("NOW"); }
   | CURRENT_DATE  { emit("NOW"); }
   | CURRENT_TIME  { emit("NOW"); }
   ;

expr: BINARY expr %prec UMINUS { emit("STR_TO_BIN"); } ;

opt_partition_expr:
     PARTITION BY expr            { $$ = 1; }
   | opt_partition_expr ',' expr  { $$ = $1 + 1; }
   ;   

opt_partition: opt_partition_expr { emit("PARTITION_BY %d", $1); } ; 

numeric_or_interval_expr:
     numeric_expr
   | interval_exp
   ;            

opt_positioning: /* nil */  { $$ = 0; }
   | PRECEDING              { $$ = 0; }
   | FOLLOWING              { $$ = 1; }
   ;

opt_partition_range: opt_partition RANGE numeric_or_interval_expr opt_positioning
                  { emit("RANGE %d %d", $3, $4); }
   ;

opt_partition_rows: opt_partition ROWS numeric_expr opt_positioning
                  { emit("ROWS %d %d", $3, $4); }
   ;

opt_partition_spec:
     opt_partition
   | opt_partition_range
   | opt_partition_rows
   ;  

opt_partition_full_spec: opt_partition_spec opt_orderby;

/*
opt_window_spec:
     opt_orderby
   | opt_partition_full_spec
   ; 

window_name: NAME;

window_spec: window_name '(' opt_window_spec ')' ;

window_ref:
     window_name
   | window_spec
   ;
*/

stmt: drop_cmd { emit("STMT"); } ;

drop_cmd:
     DROP TABLE field_name           { emit("DROP_TABLE %s", $3); free($3); }
   | DROP TABLE IF EXISTS field_name { emit("DROP_TABLE_IF_EXISTS %s", $5); free($5); }
   | DROP VDS field_name             { emit("DROP_VDS %s", $3); free($3); }
   | DROP VDS IF EXISTS field_name   { emit("DROP_VDS_IF_EXISTS %s", $5); free($5); }
   ;

stmt: solitary_semi_colon;

solitary_semi_colon: /* nil */ { $$ = 0; } ;

%%

void
emit(char *s, ...)
{
  extern int yylineno;

  va_list ap;
  va_start(ap, s);

  printf("rpn: ");
  vfprintf(stdout, s, ap);
  printf("\n");
}

void
yyerror(char *s, ...)
{
  va_list ap;
  va_start(ap, s);

  if(yylloc.first_line)
    fprintf(stderr, "%s:%d.%d-%d.%d: error: ", yylloc.filename, yylloc.first_line, yylloc.first_column,
      yylloc.last_line, yylloc.last_column);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");

}

void
lyyerror(YYLTYPE t, char *s, ...)
{
  va_list ap;
  va_start(ap, s);

  if(t.first_line)
    fprintf(stderr, "%s:%d.%d-%d.%d: error: ", t.filename, t.first_line, t.first_column,
      t.last_line, t.last_column);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}

char*
concat_strings(char *s1, char *s2, char *s3)
{
  int len = 1;
  len += strlen(s1);
  len += strlen(s2);
  len += strlen(s3);
  char *buf = (char*) _alloca(len);
  strcpy(buf, s1);
  strcat(buf, s2);
  strcat(buf, s3);
  return strdup(buf);
}

int main(int ac, char **av)
{
  extern FILE *yyin;

  if(ac > 1 && !strcmp(av[1], "-d")) {
    yydebug = 1; ac--; av++;
  }

  if(ac > 1) {
    if((yyin = fopen(av[1], "r")) == NULL) {
      perror(av[1]);
      exit(1);
    }
    filename = av[1];
  } else
    filename = "(stdin)";

  if(!yyparse())
    printf("SQL parse worked\n");
  else
    printf("SQL parse failed\n");
} /* main */
