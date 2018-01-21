module Model
    exposing
        ( Category
        , CategoryMode(..)
        , Company
        , CompanyListRouteData
        , CompanyRouteData
        , Filter
        , Model
        , Route(..)
        , emptyFilter
        , initialModel
        , newCompany
        )

import RemoteData
import WebData exposing (WebData)


type Route
    = CompanyListRoute CompanyListRouteData
    | CompanyRoute CompanyRouteData


type alias CompanyListRouteData =
    { companies : WebData (List Company), categories : List Category, filter : Filter }


type alias CompanyRouteData =
    { companies : WebData (List Company), company : Company, categories : List Category, categoryMode : CategoryMode, filter : Filter }


type alias Filter =
    { phoneNumber : String
    , category : Maybe Int
    }


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
    CompanyListRoute
        { companies = WebData.RemoteData RemoteData.Loading
        , categories = []
        , filter = emptyFilter
        }


emptyFilter : Filter
emptyFilter =
    { phoneNumber = "", category = Nothing }


type alias Category =
    { id : Maybe Int
    , name : String
    }
