module Model
    exposing
        ( Category
        , CategoryMode(..)
        , Company
        , CompanyId(..)
        , Model
        , Route(..)
        , companyId
        , initialModel
        , isNewCompany
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


type CompanyId
    = NewCompany
    | CompanyId Int


isNewCompany : Company -> Bool
isNewCompany company =
    case company.id of
        NewCompany ->
            True

        CompanyId _ ->
            False


type alias Company =
    { id : CompanyId
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


companyId : Company -> Maybe Int
companyId company =
    case company.id of
        NewCompany ->
            Nothing

        CompanyId id ->
            Just id


newCompany : Company
newCompany =
    { id = NewCompany
    , name = ""
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


type alias Category =
    String
