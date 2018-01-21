module Msg exposing (CompanyMsg(..), Msg(..))

import Model exposing (Company)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | GetCompaniesCompleted (WebData (List Company))
    | NewCompanyClicked (List Company)
    | CompanyMsg CompanyMsg
    | DeleteCompanyClicked Int
    | EditCompanyClicked Int


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
    | GetCategoriesCompleted (WebData (List Model.Category))
