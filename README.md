## Dependencies

- `http-conduit` as HTTP client.
- `bytestring` and `case-insensitive` as transitive dependencies of `http-conduit`
- `aeson` provides such things like `FromJSON` and `ToJSON` useful for serializing DTO's.
- `SHA` helps with authorized requests to CoinEx, that must be signed with secret key using HMAC.

## Language extensions

```haskell
{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, InstanceSigs #-}
```

- `OverloadedStrings` allows implicit cast for String literals to ByteString.
- `DeriveGeneric` allows automatic parsing for Generic derives with FromJSON.
- `ScopedTypeVariables` allows to use type variables in scope of a function.
- `InstanceSigs` allows to explicitly specify signatures of methods inside instance declarations.