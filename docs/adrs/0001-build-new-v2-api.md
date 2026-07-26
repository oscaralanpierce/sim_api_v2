# 0001. Build New V2 API

## Date

2026-07-25

## Approved By

@oscaralanpierce

## Decision

We will rebuild the back-end API with a new data model.

## Glossary

- **Aggregate List:** In SIM's wish list and inventory features, a non-editable list that aggregates quantities of in-game wish-list or inventory items across multiple child lists 
- **Canonical Model:** An approach to data validation used in the first version of the Skyrim Inventory Management API to ensure that in-game items created by users for a particular playthrough represented actual items that existed, or could exist, in Skyrim
- **[Creation Club](https://en.uesp.net/wiki/Skyrim:Creation_Club):** An in-game microtransactional store for Skyrim Special Edition; certain Creation Club mods, which constitute official Bethesda content, were subsequently packaged with certain game releases
- **Downloadable Content (DLC):** In the context of Skyrim, one of three mods packaged with the game starting with the Game of the Year Edition: Dawnguard, Dragonborn, and Hearthfire
- **Enterprise Resource Planning (ERP) Software:** An enterprise software solution that enables organisations to manage logistics, procurement and inventory
- **Mod:** A piece of third-party software that can be installed to make modifications to a game, such as adding new quests, modifying the difficulty of the game, changing character dialogue, or any of numerous other types of changes

## Context

It has become clear over time that canonical models are a problematic approach to data validation. Requiring every in-game item to match a canonical model of any of several classes according to complex logic can create friction for users, result in suboptimal application performance, and prevent flexibility to support mods and new game releases. Skyrim Inventory Management has always been an application that supports in-game logistics, so it should be designed more like a logistics application.

There are other aspects of SIM's data model that are problematic as well. The creation of aggregate lists to aggregate quantities of items across multiple wish or inventory lists was a mistake. Requiring inventory or wish list items to match canonical models, which could be any of various classes (`Canonical::Weapon`, `Canonical::Armor`, `Canonical::Book`, etc.), matching items on multiple lists that correspond to the same canonical model, and then aggregating the quantities of those items in a special tracking list adds massively more complexity and performance overhead than is required for the actual task at hand: managing inventory and logistics across multiple properties.

## Alternatives Considered

It's clear that we need a different approach to data modelling and that that approach is incompatible with the tables we already have. With that in mind, the alternatives being considered in this ADR are:

1. Rebuild the API with a new data model
2. Implement a migration strategy to change the data model to a desired end state over time

## Considerations

### Data Modelling Complexity

SIM's data modelling complexity is the primary factor we are considering in making the decision to rebuild rather than migrate. We want to move towards a more ERP-like structure, which is fundamentally a ledger - much simpler than the existing approach.

#### Challenges with Canonical Models

Canonical models don't work well for data validation and lack the flexibility to accommodate mods and differing game editions. Given the multitude of possible in-game item types - there are 15 canonical models, not including join tables, in the original version of SIM, as well as semi-canonical models like `Enchantment` and `AlchemicalProperty` - database relations quickly become complex and onerous. The original implementation of SIM had polymorphic associations between in-game items and their corresponding canonical models, including polymorphic join tables. Every time an item was added to an inventory or wish list, it had to be validated against and associated to a canonical model under the hood, and then checked against that canonical model - with logic that differed from class to class - to perform data validations that were not always straightforward.

#### Challenges with Aggregate Lists

Canonical models became especially problematic when combined with the aggregating behaviour used for wish lists and inventory lists. Not only did each list item have to correspond to an actual canonical model (whose class wasn't necessarily automatically known), but a special class of list had to aggregate quantities corresponding to the same canonical model across multiple lists. This meant that any changes to the items on each list had to also be checked against the canonical models and reconciled with the aggregate list item and, by extension, items on other child lists. For example, if List A and List B both contain iron ingots with a unit weight of 1, what happens when one list item is edited to make the unit weight 2? Is that weight updated across all lists? Which list should be considered most recently edited, given that we want users to see their lists and items in an order determined by when they were updated?

#### Inability to Support Mods or New Game Editions

Mods, including DLCs and Creation Club content, can change which items are available in the game as well as the properties of items that may exist in other game versions. For example, an item that is unique in the base game could have other copies in a mod or new release. The canonical model approach prevents mods from being fully supported as objects would have to be scoped to the mods or content that adds them, and there could be multiple versions of an item depending on the mods a player has installed. For example, if an item is unique in the base game but a mod adds multiple copies, there would need to be multiple canonical models, associated to specific content, to indicate that the item may or may not be unique.

### Similarity to Existing Model

While the new data model has not been finalised at the time of this ADR, it is clear that it will be quite different to what we have. This means we may want data that is currently stored in one table to be stored in different models with different tables, for example. The fact there is not anything approaching a one-to-one correspondence between the tables we have and the tables we need supports a rebuild.

### Technical Debt

Migrations tend to add technical debt to systems that needs to be cleaned up later - and cleanup can be costly, if feasible at all. Since the SIM API is not under heavy production load and does not require high availability during the migration, it makes more sense to rebuild. Rebuilding is likely to be faster, easier, and result in a better overall outcome.

### Front-End Considerations

Drastic changes to SIM's data modelling will entail also rebuilding the front end. We conclude that this is necessary since the existing data modelling is not serving the purpose of the application: managing inventory and logistics in Skyrim.

## Summary

Fundamentally, a critical look at the existing SIM structure reveals it is incompatible with the ERP/ledgering-style application that we need to facilitate actual inventory management in Skyrim. There is little use for the data we have, in the form we have it in, in the application that needs to exist. As such, building a V2 API makes more sense than attempting to salvage the API we have.

The design of the new API and its data model will be the subject of other ADRs.