# 0003. Use PostgreSQL

## Date

2026-07-27

## Approved By

@oscaralanpierce

## Decision

We will use PostgreSQL as our database engine for the V2 back end.

## Glossary

- **Expression Index:** An index created on the result of a function or scalar expression
  computed from one or more table columns, rather than on raw column data itself; also known
  as a "functional index"
- **Functional Index:** See "Expression Index"
- **Generalized Inverted Index (GIN):** A PostgreSQL feature designed to index composite
  values such as arrays and JSONB, making it ideal for queries that search for specific
  elements within these data types
- **JSONB:** A PostgreSQL data type that stores JSON data in a binary format, optimized
  for querying and indexing, unlike the standard JSON type that stores raw text
- **NoSQL Database:** Any of several types of non-relational datastores, with common examples
  being MongoDB and DynamoDB
- **Object-Relational Mapping (ORM):** Software that maps conceptual models in an object-
  oriented program to tables in a relational database; Rails ships with Active Record as
  an out-of-the-box ORM solution
- **Platform as a Service (PaaS):** A service that provides web infrastructure, such as
  web, application, and database servers, on a subscription basis; ideal for small teams
  or those that don't want to invest in infrastructure or site reliability engineers
- **PostgreSQL:** A popular open-source relational database engine
- **Single-Table Inheritance (STI):** An ORM pattern, often considered an antipattern, in
  which multiple similar models are stored in a single table and differentiated by a `type`
  column; there may be one or more other columns that are exclusive to a particular type or
  types as well, or the type may determine valid values for other columns

## Context

We have taken stock of the key desired features for the SIM V2 API. As described in [ADR
0002](/docs/adrs/0002-build-new-v2-api.md), we have had issues with canonical models stored
in different relational database tables and have decided on an approach, to be described in
a future ADR, using JSONB data stored in a single table to strike a balance between accurately
describing different types of objects and developing a byzantine data model.

## Alternatives Considered

We considered two main alternatives to PostgreSQL:

- Another relational database engine, such as MySQL
- A NoSQL database like MongoDB

## Considerations

### JSONB Support in PostgreSQL

PostgreSQL's robust support for JSONB rather than just text-based JSON columns elevates it
to first place above the alternatives. JSONB columns in Postgres will give us the flexibility
to validate data schemas without having to rely on multiple tables or use a single-table-
inheritance (STI) pattern. 

### Benefits of a Relational Engine

Sticking to a relational database enables us to enforce relationships between tables via foreign
keys, which is not possible with a NoSQL solution. While some of the same data integrity can be
enforced by other methods, it is not natively supported in a NoSQL database the way it is in a
relational database.

### Flexible Indexing

Factoring in flexible indexing, such as GIN indexing and expression indexing, which are not
available in other relational database engines, PostgreSQL becomes the clear front runner.

### Support in Render

[Render](https://render.com), our PaaS platform, only supports PostgreSQL as a relational
database. While it would be possible to change PaaS providers if we had a good enough reason,
since PostgreSQL looks like the best option anyway, this is a plus as well.

## Summary

Due to the power and flexibility of its JSONB support and indexing options, we will use
PostgreSQL for our database engine.
