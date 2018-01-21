module WebData
    exposing
        ( WebData(..)
        , error
        , getErrorMessage
        , isFailure
        , isLoading
        , loading
        , map
        , toMaybe
        )

import Http
import RemoteData


type WebData data
    = Reloading data
    | FailureWithData Http.Error data
    | RemoteData (RemoteData.WebData data)


loading : WebData a -> WebData a
loading webData =
    case webData of
        Reloading a ->
            Reloading a

        FailureWithData e a ->
            Reloading a

        RemoteData (RemoteData.Success a) ->
            Reloading a

        _ ->
            RemoteData RemoteData.Loading


isLoading : WebData a -> Bool
isLoading webData =
    case webData of
        Reloading a ->
            True

        RemoteData RemoteData.Loading ->
            True

        _ ->
            False


error : Http.Error -> WebData data -> WebData data
error error webData =
    case webData of
        Reloading a ->
            FailureWithData error a

        FailureWithData e a ->
            FailureWithData error a

        RemoteData (RemoteData.Success a) ->
            FailureWithData error a

        RemoteData (RemoteData.Failure e) ->
            RemoteData (RemoteData.Failure error)

        RemoteData RemoteData.Loading ->
            RemoteData (RemoteData.Failure error)

        RemoteData RemoteData.NotAsked ->
            RemoteData (RemoteData.Failure error)


toMaybe : WebData data -> Maybe data
toMaybe webData =
    case webData of
        Reloading a ->
            Just a

        FailureWithData e a ->
            Just a

        RemoteData (RemoteData.Success a) ->
            Just a

        RemoteData _ ->
            Nothing


map : (a -> b) -> WebData a -> WebData b
map f webData =
    case webData of
        Reloading a ->
            Reloading (f a)

        FailureWithData e a ->
            FailureWithData e (f a)

        RemoteData (RemoteData.Success a) ->
            RemoteData (RemoteData.Success (f a))

        RemoteData (RemoteData.Failure e) ->
            RemoteData (RemoteData.Failure e)

        RemoteData RemoteData.Loading ->
            RemoteData RemoteData.Loading

        RemoteData RemoteData.NotAsked ->
            RemoteData RemoteData.NotAsked


isFailure : WebData a -> Bool
isFailure webData =
    case webData of
        Reloading a ->
            False

        FailureWithData e a ->
            True

        RemoteData (RemoteData.Success a) ->
            False

        RemoteData (RemoteData.Failure e) ->
            True

        RemoteData RemoteData.Loading ->
            False

        RemoteData RemoteData.NotAsked ->
            False


getErrorMessage : WebData a -> Maybe String
getErrorMessage webData =
    case webData of
        Reloading a ->
            Nothing

        FailureWithData e a ->
            Just (getHttpErrorMessage e)

        RemoteData (RemoteData.Success a) ->
            Nothing

        RemoteData (RemoteData.Failure e) ->
            Just (getHttpErrorMessage e)

        RemoteData RemoteData.Loading ->
            Nothing

        RemoteData RemoteData.NotAsked ->
            Nothing


getHttpErrorMessage : Http.Error -> String
getHttpErrorMessage error =
    case error of
        Http.BadUrl str ->
            str

        Http.NetworkError ->
            "A network error has occured."

        Http.Timeout ->
            "It took too long for the server to respond."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload str response ->
            str
