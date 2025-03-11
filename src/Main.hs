module Main (main) where

import Presentation.Config as Config
import Presentation.UI
import Presentation.DI
import Presentation.EventLoop

import Domain.Entity.State as State
import Domain.Actor.Exchange
import Domain.Actor.Bot
import Data.Actor.CoinExExchange as CoinExExchange
import Domain.Actor.Logger
import Data.Actor.Logger
import Domain.DI
import Domain.Actor.StateDataSource as StateDataSource
import Data.Actor.FileStateDataSource
import Data.Utils (getOrThrow, RuntimeException(..))

import Control.Monad.Reader
import Control.Monad.State

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
            let withDI = \f -> runReaderT f $ DependencyHolder logger

            info logger tag "Starting..."
            debug logger tag $ show (config :: Config)

            -- check exchange
            debug logger tag "Checking if exchange is reachable..."
            pong <- withDI CoinExExchange.ping
            if pong /= "pong" then
                err logger tag "Exchange unavailable. Stop."
            else do
                -- join event loop
                debug logger tag "Exchange responded. Join event loop. Press enter key to safely exit."
                let handler = \event -> do
                        debug logger tag ("Handle \"" ++ (show event) ++ "\" looper event.")

                        let callback =
                                case event of
                                    START -> onCreate bot
                                    INVALIDATE -> invalidate bot
                                    STOP -> finish bot

                        hasState <- liftIO $ has stateSource
                        suppliedState <-
                            if hasState then liftIO $ do
                                debug logger tag "Restoring saved state..."
                                state <- StateDataSource.get stateSource
                                return state
                            else do
                                debug logger tag "No saved state. Fetching data from exchange..."
                                rate <- withDI $ getRate exchange (Config.baseCurrency config) (Config.quoteCurrency config)
                                balance <- withDI $ getBalance exchange
                                return State {
                                    State.baseCurrency = Config.baseCurrency config,
                                    State.quoteCurrency = Config.quoteCurrency config,
                                    cell = rate,balance = balance
                                }

                        if not (suppliedState `correspondsTo` config) then
                            err logger tag
                                "Saved state doesn't correspond to the current configuration. \
                                \\nUse the same currencies or remove stale state."
                        else do
                            debug logger tag "State supplied."
                            producedState <- execStateT (withDI callback) suppliedState
                            debug logger tag "Saving state..."
                            liftIO $ set stateSource producedState
                            debug logger tag "Saved."
                            return ()

                joinIntervalLoop (tick config) handler
                info logger tag "Finished."

-- Utils --

correspondsTo :: State.State -> Config -> Bool
state `correspondsTo` config = -- backticks "`" mark function as infix
    State.baseCurrency state == Config.baseCurrency config && State.quoteCurrency state == Config.quoteCurrency config

-- Constants --

tag :: String
tag = "Main"