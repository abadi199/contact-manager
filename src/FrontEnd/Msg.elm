module Msg exposing (Msg(..), NewCompanyMsg(..))

import Model exposing (Company, NewCompany)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | GetCompaniesCompleted (WebData (List Company))
    | NewCompanyClicked (List Company)
    | NewCompanyMsg NewCompanyMsg
    | DeleteCompanyClicked Int


type NewCompanyMsg
    = CancelNewCompanyClicked
    | SaveNewCompanyClicked
    | SaveNewCompanyCompleted (WebData (List Company))
    | NameUpdated String
    | Address1Updated String
    | Address2Updated String
    | CityUpdated String
    | StateUpdated String
    | ZipCodeUpdated String
    | PhoneNumberUpdated String
    | FaxNumberUpdated String
    | CategoryUpdated String
