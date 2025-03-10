module Main (main) where

import Presentation.Config
import Presentation.UI
import Presentation.DI
import Presentation.EventLoop

import Domain.Entity.State
import Domain.Entity.Amount
import Domain.Actor.Exchange
import Data.Actor.CoinExExchange as CoinExExchange
import Domain.Actor.Logger
import Data.Actor.Logger
import Domain.DI
import Domain.Actor.StateDataSource
import Data.Actor.FileStateDataSource
import Data.Utils (getOrThrow, RuntimeException(..))

import Control.Monad.Reader

main :: IO ()
main = do
    -- get CLI args
    unresolvedConfig <- args :: IO (Maybe Config)
    case unresolvedConfig of
        Nothing -> printHelp
        Just _ -> do
            let config = getOrThrow RuntimeException unresolvedConfig
            printConfig config

            -- resolve dependencies
            let logger = injectLogger
            let exchange = injectExchange config
            let stateSource = injectStateSource
            let bot = injectBot config

            info logger tag "Starting..."
            debug logger tag $ show (config :: Config)

            -- check exchange
            debug logger tag "Checking if exchange is reachable..."
            pong <- CoinExExchange.ping
            if pong /= "pong" then
                err logger tag "Exchange unavailable. Stop."
            else do
                debug logger tag "Exchange responded. Passing control to the looper..."
                let handler = \event -> debug logger tag ("Handling looper event: " ++ (show event))
                joinIntervalLoop (tick config) handler
                info logger tag "Finished."

-- Constants --

tag :: String
tag = "Main"