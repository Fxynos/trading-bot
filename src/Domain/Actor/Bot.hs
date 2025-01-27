module Domain.Actor.Bot (Bot(..)) where

import Domain.Entity.State

class Bot b where
    onCreate :: b -> State -> ()
    invalidate :: b -> ()
    finish :: b -> State