# 0006. Consolidate Inventory and Procurement Lists into Operational Ledger

## Date

2026-07-27

## Approved By

@oscaralanpierce

## Decision

Instead of duplicating the wish list/inventory list pattern used in the V1 back end, we will
use an operational ledger model indicating if an item is in inventory or for procurement.

## Glossary

- **Operational Ledger:** A book or record in which operational data is regularly recorded

## Context

We want to conceptualize SIM's core purpose as having to do with logistics. Applications that
assist in managing inventory and procurement use an operational ledger to store items on a single
list, with inventory and procurement being conceptualized as states of items on the list rather
as a distinguishing characteristic of distinct conceptual models.

Logistics operations relevant to SIM are categorized thusly:

- Procurement
- Warehousing and inventory management
- Distribution logistics

These are also fundamental stages of supply chain management, so it makes sense to think of
them as conceptually linked rather than distinct ideas. Transaction ledgers are used to track
items as they move through facilities and distribution channels.

## Alternatives Considered

The main alternative we considered was the model used in the V1 backend, i.e., separate
inventory and wish lists with (eventually) logic to "convert" a wish list item into an inventory
list item.

## Considerations

In the V1 data model, the idea that inventory and wish lists were stages of the same item rather
than something completely distinct was reflected in the fact that a canonical model had to back both
the inventory item and the wish list item. However, this resulted in a lot of complexity and more
database tables and records than would be required if we saw these as states of the same thing.
Using a ledger to track item state is a more logical approach than creating artificial categories
and moving items between them.

This approach can also eliminate the need for multiple inventory or wish lists tracked by aggregate
lists, another pain point in V1. We can filter or group items by location or other attributes on the
front end, reducing complex and slow backend logic.

## Summary

We will use a ledgering approach to manage inventory and wish lists rather than viewing these as
conceptually distinct lists.

## Further Reading

- [What are Logistics Operations in Supply Chain Management?](https://www.packsend.com.au/blog/logistics-operations/)