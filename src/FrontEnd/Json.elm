module Json exposing (companiesDecoder, companyEncoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Model exposing (Company)


companiesDecoder : Decoder (List Company)
companiesDecoder =
    list companyDecoder


companyDecoder : Decoder Company
companyDecoder =
    decode Company
        |> required "id" (Json.Decode.map Model.CompanyId int)
        |> required "name" string
        |> required "address1" string
        |> required "address2" string
        |> required "city" string
        |> required "state" string
        |> required "zipCode" string
        |> required "phoneNumber" string
        |> required "faxNumber" string
        |> required "category" string


companyEncoder : Company -> Json.Encode.Value
companyEncoder company =
    Json.Encode.object
        [ ( "id", companyIdEncoder company.id )
        , ( "name", Json.Encode.string company.name )
        , ( "address1", Json.Encode.string company.address1 )
        , ( "address2", Json.Encode.string company.address2 )
        , ( "city", Json.Encode.string company.city )
        , ( "state", Json.Encode.string company.state )
        , ( "zipCode", Json.Encode.string company.zipCode )
        , ( "phoneNumber", Json.Encode.string company.phoneNumber )
        , ( "faxNumber", Json.Encode.string company.faxNumber )
        , ( "category", Json.Encode.string company.category )
        ]


companyIdEncoder : Model.CompanyId -> Json.Encode.Value
companyIdEncoder companyId =
    case companyId of
        Model.NewCompany ->
            Json.Encode.int 0

        Model.CompanyId id ->
            Json.Encode.int id
