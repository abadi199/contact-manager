module Model
    exposing
        ( Company
        , Model
        , NewCompany
        , Route(..)
        , initialModel
        , newCompany
        )

import RemoteData
import WebData exposing (WebData)


type Route
    = CompanyListRoute { companies : WebData (List Company) }
    | NewCompanyRoute { companies : WebData (List Company), newCompany : NewCompany }


type alias Model =
    Route


type alias Company =
    { id : Int
    , name : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , zipCode : String
    , phoneNumber : String
    , faxNumber : String
    , category : String
    }


type alias NewCompany =
    { name : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , zipCode : String
    , phoneNumber : String
    , faxNumber : String
    , category : String
    }


newCompany : NewCompany
newCompany =
    { name = ""
    , address1 = ""
    , address2 = ""
    , city = ""
    , state = ""
    , zipCode = ""
    , phoneNumber = ""
    , faxNumber = ""
    , category = ""
    }


initialModel : Model
initialModel =
    CompanyListRoute { companies = WebData.RemoteData RemoteData.Loading }
