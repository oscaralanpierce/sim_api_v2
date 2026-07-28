# Playthroughs

Playthroughs represent playthroughs belonging to the [logged-in user](/docs/api/authentication.md).
All routes require authentication via Google.

## Table of Contents

- [POST /playthroughs](#post-playthroughs)
  - [Example Requests](#example-requests)
  - [Success Responses](#success-responses)
    - [Statuses](#statuses)
    - [Example Bodies](#example-bodies)
  - [Error Responses](#error-responses)
    - [Statuses](#statuses-1)
    - [Example Bodies](#example-bodies-1)

## POST /playthroughs

Creates a new playthrough for the logged-in user, returning its attributes in the response body. The request body may include a `playthrough` object, which may include `name` and `description` keys. User ID is set automatically to the ID of the logged-in user. If no `name` is included, a default name will be set. An empty or missing `playthrough` object is valid since no params are required.

### Example Requests

Request with no request body (will result in a default name being given to the new playthrough):
```
POST /playthroughs
Authorization: Bearer xxxxxxx
```

Request with an empty request body (will result in a default name being given to the new playthrough):
```
POST /playthroughs
Authorization: Bearer xxxxxxxx
Content-Type: application/json
{
  "playthrough": {}
}
```

Request with a request body specifying a name and description:
```
POST /playthroughs
Authorization: Bearer xxxxxxxx
Content-Type: application/json
{
  "playthrough": {
    "name": "My Non Default Playthrough Name",
    "description": "My non-default playthrough"
  }
}
```

### Success Responses

#### Statuses

- 201 Created

#### Example Bodies

```json
{
  "id": 83226,
  "user_id": 20082,
  "name": "My Playthrough 1",
  "description": "This could also be null",
  "created_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00",
  "updated_at": "Thu, 17 Jun 2021 11:59:16.891338000 UTC +00:00"
}
```

### Error Responses

#### Statuses

- 422 Unprocessable Entity
- 500 Internal Server Error

#### Example Bodies

A 422 response results from a validation error when the attributes provided in the request don't pass validations or fail database constraints in the API. This response indicates no playthrough was created. It includes an array of errors that prevented the playthrough from being created:
```json
{
  "errors": ["Name must be unique"]
}
```

A 500 error will be returned only when an unanticipated error is raised. Because the error is unanticipated, it may occur anywhere in the handling of the request. For that reason, a 500 error does not clearly indicate whether a playthrough was created or not. The response body will include the error message:
```json
{
  "errors": ["Something went horribly wrong"]
}
```