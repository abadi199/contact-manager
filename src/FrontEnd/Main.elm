module Main exposing (main)

import Api
import Html
import Model exposing (Model, initialModel)
import Msg exposing (Msg)
import Update exposing (update)
import View exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Api.getCompanies )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
