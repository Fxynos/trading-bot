{-# LANGUAGE ConstraintKinds, FlexibleContexts, GADTs, ExistentialQuantification #-}

module Domain.DI (DependencyHolder(..), AppMonad, HasDI, HasState, logger) where

import Domain.Actor.Logger
import Domain.Entity.State

import Control.Monad.IO.Class
import Control.Monad.Reader.Class
import Control.Monad.State.Class

type AppMonad m = (MonadIO m, HasDI m, HasState m)
type HasDI m = MonadReader DependencyHolder m
type HasState m = MonadState State m

data DependencyHolder where
    -- constructor uses polymorhic `Logger` param thanks to `GADTs`
    DependencyHolder :: Logger l => l -> DependencyHolder

-- `ExistentialQuantification` hides type param at constructor level
data PolymorphicLogger = forall l. Logger l => PolymorphicLogger l

instance Logger PolymorphicLogger where
    trace (PolymorphicLogger unwrappedLogger) tag level message = trace unwrappedLogger tag level message

logger :: DependencyHolder -> PolymorphicLogger
logger (DependencyHolder l) = PolymorphicLogger l