module Domain.Actor.StateDataSource (StateDataSource(..)) where

import Domain.Entity.State

class StateDataSource s where
    has :: s -> IO Bool
    get :: s -> IO State
    set :: s -> State -> IO ()