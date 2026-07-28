# Authentication

Like V1, the V2 API uses Google as a third-party identity provider. Users sign into the front end with Google and the same token is used to authenticate them on the back end. A user who has not signed in before will have an account created for them.

JSON web tokens (JWTs) from Google are included in the `Authorization` header as bearer tokens. Replace "<jwtvalue>" below with the literal value of the JWT returned from Google:

```
Authorization: Bearer <jwtvalue>
```