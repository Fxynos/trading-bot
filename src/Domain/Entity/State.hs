module Domain.Entity.State (State(..)) where

import Domain.Entity.Amount

data State = State {
    rate :: Amount,
    balance :: [Amount]
}