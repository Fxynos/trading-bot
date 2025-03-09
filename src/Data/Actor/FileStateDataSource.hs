{-# LANGUAGE DeriveGeneric, DuplicateRecordFields, ScopedTypeVariables #-}

module Data.Actor.FileStateDataSource (FileStateDataSource(..)) where

import Domain.Actor.StateDataSource
import Domain.Entity.State
import Domain.Entity.Amount
import Data.Utils (getOrThrow)

import Control.Exception
import Data.Aeson.Types
import Data.Aeson
import GHC.Generics
import Control.Exception
import System.Directory
import System.IO
import qualified Data.ByteString.Lazy as BL

data FileStateDataSource = FileStateDataSource { filePath :: String }

instance StateDataSource FileStateDataSource where
    has (FileStateDataSource filePath) = doesFileExist filePath

    get (FileStateDataSource filePath) = do
        entity <- restoreFromFile filePath
        return $ stateToDomain entity

    set (FileStateDataSource filePath) state = saveToFile filePath $ stateFromDomain state

-- Entities --

data StateEntity = StateEntity {
    baseCurrency :: String, -- ticker
    rate :: Float,
    balance :: [AmountEntity]
} deriving (Show, Generic)

instance FromJSON StateEntity
instance ToJSON StateEntity

data AmountEntity = AmountEntity {
    currency :: String,
    value :: Float
} deriving (Show, Generic)

instance FromJSON AmountEntity
instance ToJSON AmountEntity

-- Mappers --

stateToDomain :: StateEntity -> State
stateToDomain (StateEntity currency rate balance) = State {
    baseCurrency = currency,
    rate = rate,
    balance = map amountToDomain balance
}

amountToDomain :: AmountEntity -> Amount
amountToDomain (AmountEntity currency value) = Amount {
    currency = currency,
    value = value
}

stateFromDomain :: State -> StateEntity
stateFromDomain (State currency rate balance) = StateEntity {
    baseCurrency = currency,
    rate = rate,
    balance = map amountFromDomain balance
}

amountFromDomain :: Amount -> AmountEntity
amountFromDomain (Amount currency value) = AmountEntity {
    currency = currency,
    value = value
}

-- Utils --

saveToFile :: ToJSON a => String -> a -> IO ()
saveToFile filePath entity = BL.writeFile filePath $ encode entity

restoreFromFile :: forall a. FromJSON a => String -> IO a
restoreFromFile filePath = do
    content <- BL.readFile filePath
    return $ getOrThrow MalformedFileException $ decode content

data MalformedFileException = MalformedFileException deriving Show
instance Exception MalformedFileException