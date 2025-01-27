module Domain.Entity.Amount (Amount(..)) where

import Domain.Entity.Currency

data Amount = Amount {
    currency :: Currency,
    value :: Float
}