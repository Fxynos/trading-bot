## Dependencies

- `http-conduit` as HTTP client.
- `bytestring` and `case-insensitive` as transitive dependencies of `http-conduit`
- `aeson` provides such things like `FromJSON` and `ToJSON` useful for serializing DTO's.
- `SHA` helps with authorized requests to CoinEx, that must be signed with secret key using HMAC.
- `mtl` provides `Reader` to implement dependency injection.

## Language extensions

```haskell
{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, InstanceSigs, DuplicateRecordFields, ExistentialQuantification, GADTs, ConstraintKinds, FlexibleContexts #-}
```

- `OverloadedStrings` allows implicit cast for String literals to ByteString.
- `DeriveGeneric` allows automatic parsing for Generic derives with FromJSON.
- `ScopedTypeVariables` allows to use type variables in scope of a function.
- `InstanceSigs` allows to explicitly specify signatures of methods inside instance declarations.
- `DuplicateRecordFields` allows to use the same field name in different data records.
- `ExistentialQuantification` allows to add constraints in `data` declaration in order to hide type param, but still enforce the constraint.
- `GADTs` enables support for polymorphism in `data` fields.
- `ConstraintKinds, FlexibleContexts` enable support for **constraint tuples** (used with `type`).