module Model
    exposing
        ( Category
        , CategoryMode(..)
        , Company
        , Model
        , Route(..)
        , initialModel
        , newCompany
        )

import RemoteData
import WebData exposing (WebData)


type Route
    = CompanyListRoute { companies : WebData (List Company) }
    | CompanyRoute { companies : WebData (List Company), company : Company, categories : List Category, categoryMode : CategoryMode }


type CategoryMode
    = SelectCategory
    | NewCategory String


type alias Model =
    Route


type alias Company =
    { id : Maybe Int
    , name : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , zipCode : String
    , phoneNumber : String
    , faxNumber : String
    , category : Maybe Category
    }


newCompany : Company
newCompany =
    { id = Nothing
    , name = ""
    , address1 = ""
    , address2 = ""
    , city = ""
    , state = ""
    , zipCode = ""
    , phoneNumber = ""
    , faxNumber = ""
    , category = Nothing
    }


initialModel : Model
initialModel =
    CompanyListRoute { companies = WebData.RemoteData RemoteData.Loading }


type alias Category =
    { id : Maybe Int
    , name : String
    }
