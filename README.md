# sqlprsr - enhanced flex/bison grammar parser targeting Apache Calcite SQL Language

## Introduction

**sqlprsr** is an enhancement of a MySQL grammar parser depicted in the 2009-published O'Reilly book, "flex and bison". (Details of reuse and attribution are in the project [LICENSE](LICENSE).)

That grammar, per this project, is in progress of being enhanced to support the [Apache Calcite SQL Language](http://calcite.apache.org/docs/reference.html).

The Calcite SQL parser is implemented in Java and is intended for re-use in other projects. An example of a project relying on the Calcite SQL parser is [Dremio](https://www.dremio.com/), Dremio is a data-as-a-service platform.

The Calcite SQL Language supports features from the SQL 1999 and 2003 standards such as recursive queries and windowing functions.

The Dremio version of Calcite SQL language introduced the `VDS` keyword, which is a kind of materialized view. This parser accepts `VDS`.

This parser also accepts the character `'$'` appearing in table, VDS, and column names such that they do not have to be quoted, and the `'.'` separator character can appear multiple times.
```SQL
CREATE VDS $site_id.base_data_current.trucks_info AS ...
```

## Building the project

The project builds on Linux distributions - need to have `make`, `gcc`, `flex`, and `bison` all installed.

It has also been build on Windows under `mingw`, using `gcc 4.5` C compiler.

## Status

The parser is a work in progress. It has been developed against a set of a few hundred real-world SQL script files (all doing materialization of tables or VDSs where there are inter-dependencies involved) and it is successfully parsing all but around 20 of these at the time of writing (and the remaining errors are mostly minor in scope to address). The body of real-world SQL queries vary in complexity but some are 50 to 200 lines of complex SQL - nested sub selection, use of `WITH`, union set operations, windowing, etc.

The parser emits a Reverse Polish Notation - refer to the O'Reilly flex and bison book to learn more about that.

The current intention is to use this sql parser to determine dependency relationships among a large body of interrelated complex queries that are doing materialization. It may likely be used later on to enforce validations rules and possibly to extract terminal node sub select queries. This latter would constitute a kind of dissection of a complex nested query into its constituent components.
