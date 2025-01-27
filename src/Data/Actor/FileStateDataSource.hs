module Data.Actor.FileStateDataSource (FileStateDataSource(..)) where

import Domain.Actor.StateDataSource
import Control.Exception
import Data.Utils (UnimplementedException(..))

data FileStateDataSource = FileStateDataSource { filePath :: String }

instance StateDataSource FileStateDataSource where
    get dataSource = throw UnimplementedException
    set dataSource state = throw UnimplementedException