## Used language extensions

```haskell
{-# LANGUAGE OverloadedStrings, DeriveGeneric, ScopedTypeVariables #-}
```

- `OverloadedStrings` allows implicit cast for String literals to ByteString.
- `DeriveGeneric` allows automatic parsing for Generic derives with FromJSON.
- `ScopedTypeVariables` allows to use type variables in scope of a function.
- `InstanceSigs` allows to explicitly specify signatures of methods inside instance declarations.