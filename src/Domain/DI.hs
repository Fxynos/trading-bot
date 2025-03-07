{-# LANGUAGE ConstraintKinds, FlexibleContexts, GADTs, ExistentialQuantification #-}

module Domain.DI (DependencyHolder(..), AppMonad, logger) where

import Domain.Actor.Logger

import Control.Monad.IO.Class
import Control.Monad.Reader.Class

type AppMonad m = (MonadIO m, MonadReader DependencyHolder m)

data DependencyHolder where
    -- constructor uses polymorhic `Logger` param thanks to `GADTs`
    DependencyHolder :: Logger l => l -> DependencyHolder

-- `ExistentialQuantification` hides type param at constructor level
data PolymorphicLogger = forall l. Logger l => PolymorphicLogger l

instance Logger PolymorphicLogger where
    trace (PolymorphicLogger logger) tag level message = trace logger tag level message

logger :: DependencyHolder -> PolymorphicLogger
logger (DependencyHolder l) = PolymorphicLogger l