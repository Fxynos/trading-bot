module Domain.Entity.Amount (Amount(..), Currency) where

data Amount = Amount {
    currency :: Currency,
    value :: Float
} deriving Show

type Currency = String