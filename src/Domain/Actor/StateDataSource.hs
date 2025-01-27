module Domain.Actor.StateDataSource (StateDataSource(..)) where

import Domain.Entity.State

class StateDataSource s where
    get :: s -> State
    set :: s -> State -> ()