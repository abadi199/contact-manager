module Msg exposing (CompanyMsg(..), Msg(..))

import Model exposing (Category, Company)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | GetCompaniesCompleted (WebData (List Company))
    | NewCompanyClicked (List Company)
    | CompanyMsg CompanyMsg
    | DeleteCompanyClicked Int
    | DeleteCompanyConfirmed Int
    | EditCompanyClicked Int
    | GetCategoriesCompleted (WebData (List Model.Category))
    | SearchByPhoneUpdated String
    | SearchByCategoryUpdated (Maybe Int)
    | SearchClicked
    | ClearFilterClicked


type CompanyMsg
    = CancelCompanyClicked
    | SaveCompanyClicked
    | SaveCompanyCompleted (WebData (List Company))
    | NameUpdated String
    | Address1Updated String
    | Address2Updated String
    | CityUpdated String
    | StateUpdated String
    | ZipCodeUpdated String
    | PhoneNumberUpdated String
    | FaxNumberUpdated String
    | CategoryUpdated (Maybe Model.Category)
    | NewCategoryClicked
    | CategoryNameUpdated String
    | SaveNewCategoryClicked
    | SaveEditCategoryClicked
    | CancelCategoryClicked
