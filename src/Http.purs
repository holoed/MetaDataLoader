module Http where

import Data.Function
import Data.Either
import Control.Monad.Eff
import Control.Monad.Cont.Trans

foreign import data Net :: !

type ErrorCode = String
type Url = String

type M eff = Eff (fs :: Net | eff)

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
  """ :: forall eff. Fn3 Url
                         (String -> M eff Unit)
                         (ErrorCode -> M eff Unit)
                         (M eff Unit)

fetchCb :: forall eff. Url -> (Either ErrorCode String -> M eff Unit) -> M eff Unit
fetchCb url k =
   runFn3 fetchImpl
          url
          (k <<< Right)
          (k <<< Left)

type C eff = ContT Unit (M eff)

fetch :: forall eff. Url -> C eff (Either ErrorCode String)
fetch path = ContT $ fetchCb path
