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
        |> required "Id" int
        |> required "Name" string
        |> required "Address1" string
        |> required "Address2" string
        |> required "City" string
        |> required "State" string
        |> required "ZipCode" string
        |> required "PhoneNumber" string
        |> required "FaxNumber" string
        |> required "Category" string


newCompanyEncoder : NewCompany -> Json.Encode.Value
newCompanyEncoder newCompany =
    Json.Encode.object
        [ ( "Name", Json.Encode.string newCompany.name )
        , ( "Address1", Json.Encode.string newCompany.address1 )
        , ( "Address2", Json.Encode.string newCompany.address2 )
        , ( "City", Json.Encode.string newCompany.city )
        , ( "State", Json.Encode.string newCompany.state )
        , ( "ZipCode", Json.Encode.string newCompany.zipCode )
        , ( "PhoneNumber", Json.Encode.string newCompany.phoneNumber )
        , ( "FaxNumber", Json.Encode.string newCompany.faxNumber )
        , ( "Category", Json.Encode.string newCompany.category )
        ]
