module Data.Actor.GridBot (GridBot(..)) where

import Domain.DI
import Domain.Entity.Amount
import Domain.Entity.State
import Domain.Actor.Logger
import Domain.Actor.Bot
import Domain.Actor.Exchange
import Control.Exception
import Data.Utils (UnimplementedException(..))

import Control.Monad.IO.Class
import Control.Monad.State.Class
import Control.Monad.Reader.Class

data GridBot e = GridBot {
    exchange :: e,
    gap :: Float,
    orderAmount :: Float,
    baseCurrency :: Currency,
    quoteCurrency :: Currency
}

instance (Exchange e) => Bot (GridBot e) where
    onCreate bot = do
        state <- get
        logger <- asks logger
        liftIO $ do
            info logger tag "Initializing..."
            debug logger tag $ show state

    invalidate bot = do
        state <- get
        logger <- asks logger
        liftIO $ do
            info logger tag "Invalidating..."
            debug logger tag $ show state

    finish bot = do
        state <- get
        logger <- asks logger
        liftIO $ do
            info logger tag "Finishing..."
            debug logger tag $ show state

-- Constants --

tag :: String
tag = "GridBot"