module Domain.Entity.State (State(..)) where

import Domain.Entity.Currency
import Domain.Entity.Amount

data State = State {
    baseCurrency :: Currency,
    rate :: Float, -- base currency to quote one
    balance :: [Amount]
}