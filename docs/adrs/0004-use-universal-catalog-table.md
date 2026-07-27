# 0004. Use Universal Catalog Table to Represent Skyrim Data

## Date

2026-07-27

## Approved By

@oscaralanpierce

## Decision

We will use a single universal catalog table in PostgreSQL with flexible JSONB columns to
represent any in-game data in Skyrim.

## Glossary

- **Canonical Model:** An Active Record model type used in the V1 API whereby every
  possible in-game item was stored in the database, along with its possible relationships
  to other in-game items, and items created by a user during a particular playthrough
  were matched to and validated against corresponding canonical models
- **In-Game Data:** A broad class of data including in-game objects, characters,
  character types (e.g., "Bandit Marauder"), quests, and locations defined in Skyrim
- **JSONB:** A PostgreSQL data type that stores JSON data in a binary format, optimized
  for querying and indexing, unlike the standard JSON type that stores raw text
- **PostgreSQL:** A popular open-source relational database engine used in SIM for its
  flexible indexing and JSONB support (see [ADR](/docs/adrs/0003-use-postgresql.md))
- **Universal Catalog Table:** A single PostgreSQL table that encapsulates all types
  of in-game data, using JSONB schemas to associate appropriate data to each type of
  model

## Context

We have experienced firsthand the pain points of using distinct tables for each type of
canonical data in Skyrim. In the V1 API, we implemented 15 canonical models, such as
`Canonical::Weapon`, `Canonical::Book`, and `Canonical::ClothingItem`, to represent any
item in Skyrim. Had we implemented features involving quests, objectives, locations,
characters, or enemy types, this number would have surely grown further.

The drawbacks were as numerous as the rationale was understandable. Skyrim features an
impressive array of in-game items, and it is almost impossible to apply universal rules:
is a crossbow a weapon, or is it a smithing material? (After all, it is required to forge
an enhanced crossbow for players using the Dawnguard DLC.) What is the base damage of the
sword of Miraak? (Trick question: the sword is levelled and its base damage depends on the
player character's level when they obtained it.) We wanted to validate user-entered data
to verify that it was possible for it to exist in-game, but there were simply too many
variations to make this approach practical, especially when we started to think about
supporting DLCs, Creation Club content, mods, and the ever-increasing number of Skyrim
releases (after all, Bethesda wouldn't want to release Elder Scrolls 6 too soon).

## Alternatives Considered

In determining a path forward, we elaborated several other approaches that, after a few
iterations, converged into the same basic data model used in the V1 API. However, seeing
the complexity that that model introduced before we even shipped an MVP motivated us to keep
looking. While we did not find a magic bullet, we did identify a data model that would be
more flexible and bypass some of the pain points we experienced with canonical models. That
model is the universal catalog table, which enables us to store certain universal values -
for instance, all types of in-game data have a name, etc. - while using JSONB columns to
accommodate data with an unusual or unique shape.

## Considerations

We wanted to retain the ability to validate that a particular piece of data is possible in
Skyrim while bypassing disadvantages like having to categorise data too soon or know which
table to query for a canonical model that might match user input. Since this is an inventory
and logistics app, it is not without real-world parallels: every company that needs to think
about inventory and procurement wants to make sure that the items it is procuring actually
exist, and real-world items, like Skyrim items, do not always fit an easy taxonomy. JSONB is
a popular format to provide flexibility while enabling schema validation and maintaining the
ability to query the data in a performant way.

Another factor was desired relationships between models. Looking ahead to our planned
playthrough notes feature, we want notes to be able to be associated with various types of
objects: enemies, enemy types, locations, quests, objectives, and other in-game data can be
relevant, and can be relevant in combination. For example, the bandit chief in Bilegulch Mine
is much more formidable to a low-level character than a bandit chief that spawns outside Lakeview
Manor because of the characteristics of that specific space. For that reason, it is useful to
associate both an enemy type - "Bandit Chief" - and a location to notes on this encounter. Using
PostgreSQL's native support for JSONB indexing enables us to accommodate unique data while also
enabling relational associations.

Storing all data in one table makes that table more complex, but it also minimises the number of
tables we have to have and improves our ability to conceptualise items as real items that can be
used for different things and therefore have different properties that matter.

## Summary

We will use a universal catalog table to represent all in-game data, with JSONB columns used to
accommodate unique or unusual data.
