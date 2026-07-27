# 0005. Store X/Y Vectors in Universal Catalog

## Date

2026-07-27

## Approved By

@oscaralanpierce

## Decision

We will store X/Y coordinate data for in-game locations in JSONB data in the [universal
catalog](/docs/adrs/0004-use-universal-catalog-table.md).

## Glossary

- **Corridor Pathfinding:** An approach to route calculation that, given a route,
  identifies locations within a particular radius of that route to optimise stops
- **Universal Catalog:** A single table in which the SIM database will store all
  in-game items and other in-game data ([ADR](/docs/adrs/0004-use-universal-catalog-table.md))

## Context

One feature we would like to support is route planning: if I travel from Riften to
High Hrothgar along the road, which of my current quest objectives are located along
the way? Which unique objects can I collect on this route? This is a standard logistics
problem and one that is typically solved by using corridor pathfinding. Storing location
data as X/Y coordinates in the database will facilitate corridor pathfinding. It could
also be useful for inventory planning: which houses can I stop at to mix potions so I
have enough potions for the journey?

## Alternatives Considered

We considered conceptualising locations as nested boxes - `Property` -> `Room` ->
`Container` - without X/Y coordinates. This has the advantage of simplicity, but relies
on the user's knowledge and heuristics to make logistical calculations that we'd like to
eventually make programmatically.

## Considerations

Since we are using the universal catalog anyway, we don't even need to adapt the database
schema to store this data. We can add it as JSONB metadata and validate that it is included
for all locations.

This approach facilitates viewing locations in a more dynamic way, and not just as facilities
for storing items.

## Summary

We will store location coordinates in the universal catalog.
