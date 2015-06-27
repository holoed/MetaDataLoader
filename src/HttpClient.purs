module HttpClient (fetch, C(..), ErrorCode(..), Url(..)) where

import Data.Function
import Data.Either
import Control.Monad.Eff
import Control.Monad.Cont.Trans

foreign import data Net :: !

type ErrorCode = String
type Url = String

type M = Eff (fs :: Net)

foreign import fetchImpl
  """
   function fetchImpl(url, onSuccess, onFailure) {
    return function() {
     var fetch = require('node-fetch');
     console.log('requests ' + url);
     fetch(url)
       .then(function (response) { return response.json(); })
       .then(function (x) { onSuccess(x); })
       .catch(function (error) { onFailure(error); });
   };
  }
  """ :: Fn3 Url
                         (String -> M Unit)
                         (ErrorCode -> M Unit)
                         (M Unit)

fetchCb :: Url -> (Either ErrorCode String -> M Unit) -> M Unit
fetchCb url k =
   runFn3 fetchImpl
          url
          (k <<< Right)
          (k <<< Left)

type C = ContT Unit M

type Http = C (Either ErrorCode String) 


fetch :: forall eff. Url -> C (Either ErrorCode String)
fetch path = ContT $ fetchCb path
