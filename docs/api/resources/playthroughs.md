# Playthroughs

Playthroughs represent playthroughs belonging to the [logged-in user](/docs/api/authentication.md). All endpoints require authentication via Google.

## Table of Contents

- [GET /playthroughs](#get-playthroughs)
  - [Example Requests](#example-requests)
  - [Success Responses](#success-responses)
    - [Statuses](#statuses)
    - [Example Bodies](#example-bodies)
  - [Error Responses](#error-responses)
    - [Statuses](#statuses-1)
    - [Example Bodies](#example-bodies-1)
- [POST /playthroughs](#post-playthroughs)
  - [Example Requests](#example-requests-1)
  - [Success Responses](#success-responses-1)
    - [Statuses](#statuses-2)
    - [Example Bodies](#example-bodies-2)
  - [Error Responses](#error-responses-1)
    - [Statuses](#statuses-3)
    - [Example Bodies](#example-bodies-3)
- [DELETE /playthroughs/:id](#delete-playthroughsid)
  - [Example Requests](#example-requests-2)
  - [Success Responses](#success-responses-2)
    - [Statuses](#statuses-4)
    - [Example Bodies](#example-bodies-4)
  - [Error Responses](#error-responses-2)
    - [Statuses](#statuses-5)
    - [Example Bodies](#example-bodies-5)

## GET /playthroughs

Returns all playthroughs for the logged-in user, in descending order of update timestamp (i.e., the most recently updated playthroughs will be returned first).

### Example Requests

```
GET /playthroughs
Authorization: Bearer xxxxxxx
Content-Type: application/json
```

### Success Responses

#### Statuses

- 200 OK

#### Example Bodies

Response when the user has no playthroughs:
```json
[]
```

Response when the user has playthroughs:
```json
[
  {
    "id": 822,
    "user_id": 2301,
    "name": "My Playthrough 2",
    "description": "My second playthrough",
    "created_at": "Mon, 21 Jun 2026 02:36:27.173881000 UTC +00:00",
    "updated_at": "Mon, 21 Jun 2026 02:36:27.173881000 UTC +00:00"
  },
  {
    "id": 335,
    "user_id": 2301,
    "name": "My Playthrough 1",
    "description": "My first playthrough",
    "created_at": "Thu, 17 Jun 2026 11:59:16.891338000 UTC +00:00",
    "updated_at": "Thu, 17 Jun 2026 11:59:16.891338000 UTC +00:00"
  }
]
```

### Error Responses

#### Statuses

- 500 Internal Server Error

#### Example Bodies

500 errors are returned due to unexpected errors and can occur at any point during program execution:
```json
{
  "errors": ["StandardError: Something went wrong"]
}
```

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

## DELETE /playthroughs/:id

Deletes the playthrough with the given `id`, provided it exists and belongs to the authenticated user.

### Example Requests

```
DELETE /playthroughs/22
Authorization: Bearer xxxxxxx
Content-Type: application/json
```

### Success Responses

#### Statuses

- 204 No Content

#### Example Bodies

A successful deletion will not return a response body.

### Error Responses

#### Statuses

- 404 Not Found
- 500 Internal Server Error

#### Example Bodies

A 404 response is returned when the playthrough with the given `id` does not exist (or does not belong to the authenticated user). A 404 response means no playthrough was deleted:
```json
{
  "errors": ["Playthrough not found"]
}
```

A 500 error is returned when an unexpected error occurs. Because the error is unexpected and can occur at any point in the execution, a 500 error does not indicate whether a playthrough was deleted or not:
```json
{
  "errors": ["Something went horribly wrong"]
}
```