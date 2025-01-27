module Data.Actor.GridBot (GridBot(..)) where

import Domain.Actor.Bot
import Domain.Actor.Exchange
import Control.Exception
import Data.Utils (UnimplementedException(..))

data GridBot e = GridBot { exchange :: e }

instance (Exchange e) => Bot (GridBot e) where
    onCreate bot savedState = throw UnimplementedException
    invalidate bot = throw UnimplementedException
    finish bot = throw UnimplementedException