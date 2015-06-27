module Main where

import Debug.Trace
import Data.Either
import Control.Monad.Cont.Trans
import Control.Monad.Eff

import MetadataLoader

import Control.Monad.Eff.Unsafe


main = runContT (rootList) (\(Right x) -> print x)
