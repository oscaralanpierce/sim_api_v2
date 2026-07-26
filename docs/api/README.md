# API Documentation

Skyrim Inventory Management's V2 API offers endpoints allowing users to manage inventory, procurement, and logistics in their Skyrim playthroughs.

## Endpoints

Currently, the V2 API offers only a single health-check endpoint. This endpoint is not authenticated. It returns an empty 200 response if the app is running.

## Resources

Note that the `User` model is not exposed as a RESTful resource because Google is the source of truth for profile data on the front end.