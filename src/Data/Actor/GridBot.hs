{-# LANGUAGE FlexibleContexts #-}

module Data.Actor.GridBot (GridBot(..)) where

import Domain.DI
import Domain.Entity.Amount
import Domain.Entity.State as State
import Domain.Actor.Exchange
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
    orderAmount :: Float, -- in base currency
    baseCurrency :: Currency,
    quoteCurrency :: Currency
}

instance (Exchange e) => Bot (GridBot e) where
    onCreate bot = do
        state <- get
        logger <- asks logger
        liftIO $ debug logger tag $ "Initialized: " ++ (show state)

    invalidate bot = do
        state <- get
        logger <- asks logger
        liftIO $ do
            debug logger tag $ "Invalidate: " ++ (show state)
            debug logger tag "Fetching rate..."

        rate <- getRate (exchange bot) (getBaseCurrency bot) (getQuoteCurrency bot)

        if rate - (cell state) >= gap bot then do -- rate grew up
            let baseAvailable = balanceOf (getBaseCurrency bot) (balance state) -- balance of base currency

            liftIO $ debug logger tag $
                "Rate overcame another cell of grid at the top: " ++
                (show rate) ++
                ". We're about to sell " ++
                (show $ orderAmount bot) ++ " " ++ (getBaseCurrency bot) ++
                " while " ++
                (show baseAvailable) ++ " " ++ (getBaseCurrency bot) ++
                " is available."

            if baseAvailable < orderAmount bot then
                liftIO $ warn logger tag "Skip because of insufficient balance."
            else do
                liftIO $ debug logger tag "Placing FOK order..."

                isFulfilled <- placeFokOrder (exchange bot) (getBaseCurrency bot) (getQuoteCurrency bot)
                    Sell (orderAmount bot) (cell state + gap bot)

                if not isFulfilled then
                    liftIO $ warn logger tag "Skip, because FOK order couldn't be fulfilled."
                else do
                    liftIO $ info logger tag "Sell FOK order fulfilled."
                    updateState bot Up
        else if rate - (cell state) <= gap bot then do -- rate fell
            let quoteAmount = balanceOf (getQuoteCurrency bot) (balance state) -- balance of quote currency
            let baseAvailable = quoteAmount * rate -- max order amount in base currency

            liftIO $ debug logger tag $
                "Rate overcame another cell of grid at the bottom: " ++
                (show rate) ++
                ". We're about to buy " ++
                (show $ orderAmount bot) ++ " " ++ (getBaseCurrency bot) ++
                " while " ++
                (show baseAvailable) ++ " " ++ (getBaseCurrency bot) ++
                " is max available amount to be purchased (" ++
                (show quoteAmount) ++ " " ++ (getQuoteCurrency bot) ++
                ")."

            if baseAvailable < orderAmount bot then
                liftIO $ warn logger tag "Skip because of insufficient balance."
            else do
                liftIO $ debug logger tag "Placing FOK order..."

                isFulfilled <- placeFokOrder (exchange bot) (getBaseCurrency bot) (getQuoteCurrency bot)
                    Buy (orderAmount bot) (cell state - gap bot)

                if not isFulfilled then
                    liftIO $ warn logger tag "Skip, because FOK order couldn't be fulfilled."
                else do
                    liftIO $ info logger tag "Buy FOK order fulfilled."
                    updateState bot Down
                    updatedState <- get
                    liftIO $ debug logger tag $ "Update state: " ++ (show updatedState)
        else liftIO $ debug logger tag $ "Do nothing. Current rate: " ++ (show rate) -- rate didn't change significally

    finish bot = do
        state <- get
        logger <- asks logger
        liftIO $ debug logger tag $ "Finished: " ++ (show state)

-- Utils --

balanceOf :: Currency -> [Amount] -> Float
balanceOf currency balance = head ([value | (Amount c value) <- balance, c == currency] ++ [0])

{- Updates current grid cell and balance -}
updateState :: (AppMonad m, Exchange e) => GridBot e -> CellChange -> m ()
updateState (GridBot exchange gap _ _ _) cellChange = do
    let cellDelta = case cellChange of
            Up -> gap
            Down -> -gap

    logger <- asks logger
    liftIO $ debug logger tag "Fetching balance..."
    balance <- getBalance exchange
    liftIO $ debug logger tag "Balance received."
    state <- get
    put State {
        -- not affected
        State.baseCurrency = State.baseCurrency state,
        State.quoteCurrency = State.quoteCurrency state,
        -- updated
        cell = (cell state) + cellDelta,
        balance = balance
    }

data CellChange = Up | Down

getBaseCurrency :: GridBot e -> Currency
getBaseCurrency (GridBot _ _ _ base _) = base

getQuoteCurrency :: GridBot e -> Currency
getQuoteCurrency (GridBot _ _ _ _ quote) = quote

-- Constants --

tag :: String
tag = "GridBot"