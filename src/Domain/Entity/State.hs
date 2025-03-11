module Domain.Entity.State (State(..)) where

import Domain.Entity.Currency
import Domain.Entity.Amount

data State = State {
    baseCurrency :: Currency,
    cell :: Float, -- rate of quote currency to base one
    balance :: [Amount]
} deriving Show