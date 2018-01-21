module Json exposing (companiesDecoder, newCompanyEncoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Model exposing (Company, NewCompany)


companiesDecoder : Decoder (List Company)
companiesDecoder =
    list companyDecoder


companyDecoder : Decoder Company
companyDecoder =
    decode Company
        |> required "id" int
        |> required "name" string
        |> required "address1" string
        |> required "address2" string
        |> required "city" string
        |> required "state" string
        |> required "zipCode" string
        |> required "phoneNumber" string
        |> required "faxNumber" string
        |> required "category" string


newCompanyEncoder : NewCompany -> Json.Encode.Value
newCompanyEncoder newCompany =
    Json.Encode.object
        [ ( "name", Json.Encode.string newCompany.name )
        , ( "address1", Json.Encode.string newCompany.address1 )
        , ( "address2", Json.Encode.string newCompany.address2 )
        , ( "city", Json.Encode.string newCompany.city )
        , ( "state", Json.Encode.string newCompany.state )
        , ( "zipCode", Json.Encode.string newCompany.zipCode )
        , ( "phoneNumber", Json.Encode.string newCompany.phoneNumber )
        , ( "faxNumber", Json.Encode.string newCompany.faxNumber )
        , ( "category", Json.Encode.string newCompany.category )
        ]
