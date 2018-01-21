module Json
    exposing
        ( categoryDecoder
        , companiesDecoder
        , companyEncoder
        )

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Model exposing (Category, Company)


companiesDecoder : Decoder (List Company)
companiesDecoder =
    list companyDecoder


companyDecoder : Decoder Company
companyDecoder =
    decode Company
        |> required "id" (Json.Decode.map Just int)
        |> required "name" string
        |> required "address1" string
        |> required "address2" string
        |> required "city" string
        |> required "state" string
        |> required "zipCode" string
        |> required "phoneNumber" string
        |> required "faxNumber" string
        |> required "category" (Json.Decode.map Just categoryDecoder)


companyEncoder : Company -> Json.Encode.Value
companyEncoder company =
    Json.Encode.object
        [ ( "id", Json.Encode.int <| Maybe.withDefault 0 <| company.id )
        , ( "name", Json.Encode.string company.name )
        , ( "address1", Json.Encode.string company.address1 )
        , ( "address2", Json.Encode.string company.address2 )
        , ( "city", Json.Encode.string company.city )
        , ( "state", Json.Encode.string company.state )
        , ( "zipCode", Json.Encode.string company.zipCode )
        , ( "phoneNumber", Json.Encode.string company.phoneNumber )
        , ( "faxNumber", Json.Encode.string company.faxNumber )
        , ( "categoryId", Json.Encode.int <| Maybe.withDefault 0 <| Maybe.andThen .id <| company.category )
        ]


categoryDecoder : Decoder Category
categoryDecoder =
    decode Category
        |> required "id" (Json.Decode.map Just int)
        |> required "name" string
