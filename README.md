## Requirements

[The Haskell Tool Stack](https://docs.haskellstack.org/en/stable/) is required to run the project.

## Run

- To see help message:
```bash
stack run
```

- To launch trading bot:
```bash
stack run -- --tick 15000 --gap 1.5 --amount 4.5 --base DNX --quote USDT --id 0123456789ABCDEF --key 0123456789ABCDEF 
```

- To filter logs:
```bash
grep -E "^[^ ]* [^ ]* *(INFO|WARNING|ERROR)" temp/log.txt
```

## Dependencies

- `http-conduit` as HTTP client.
- `bytestring` and `case-insensitive` as transitive dependencies of `http-conduit`
- `aeson` provides such things like `FromJSON` and `ToJSON` useful for serializing DTO's.
- `SHA` helps with authorized requests to CoinEx, that must be signed with secret key using HMAC.
- `mtl` provides `Reader` to implement dependency injection and `State` for state management.
- `time` is used by logger for timestamps.
- `containers` provides `Map`.
- `directory` provides `doesFileExist` function.
- `timers`, `suspend` provide `Timer` and `Delay` for [EventLoop](src/Presentation/EventLoop.hs).

## Language extensions

```haskell
{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables, InstanceSigs, DuplicateRecordFields, ExistentialQuantification, GADTs, ConstraintKinds, FlexibleContexts, NumericUnderscores #-}
```

- `OverloadedStrings` allows implicit cast for String literals to ByteString.
- `DeriveGeneric` allows automatic parsing for Generic derives with FromJSON.
- `ScopedTypeVariables` allows to use type variables in scope of a function.
- `InstanceSigs` allows to explicitly specify signatures of methods inside instance declarations.
- `DuplicateRecordFields` allows to use the same field name in different data records.
- `ExistentialQuantification` allows to add constraints in `data` declaration in order to hide type param, but still enforce the constraint.
- `GADTs` enables support for polymorphism in `data` fields.
- `ConstraintKinds`, `FlexibleContexts` enable support for **constraint tuples** (used with `type`).
- `NumericUnderscores` allows underscore syntax for number literals (`100_000`). 