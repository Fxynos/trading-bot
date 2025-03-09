module Presentation.DI (injectLogger, injectExchange, injectStateSource, injectBot) where

import Presentation.Config as Config

import Domain.Actor.Logger
import Domain.Actor.Exchange
import Domain.Actor.StateDataSource
import Domain.Actor.Bot

import Data.Actor.Logger
import Data.Actor.CoinExExchange as CoinExExchange
import Data.Actor.FileStateDataSource
import Data.Actor.GridBot

-- Bindings --

injectLogger :: CompositeLogger
injectLogger = CompositeLogger [
        (CompositeLoggerItem TerminalLogger),
        (CompositeLoggerItem $ FileLogger logFilePath)
    ]

injectExchange :: Config -> CoinExExchange
injectExchange config = CoinExExchange {
   CoinExExchange.accessId = Config.accessId config,
   CoinExExchange.secretKey = Config.secretKey config
}

injectStateSource :: FileStateDataSource
injectStateSource = FileStateDataSource { filePath = stateFilePath }

injectBot :: Config -> GridBot CoinExExchange
injectBot config = GridBot { exchange = injectExchange config }

-- Constants --

logFilePath :: String
logFilePath = "temp/log.txt"

stateFilePath :: String
stateFilePath = "temp/state.json"