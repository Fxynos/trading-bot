module Data.Utils (UnimplementedException(..)) where

import Control.Exception

data UnimplementedException = UnimplementedException deriving Show
instance Exception UnimplementedException