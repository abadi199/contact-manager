module Api exposing (getCompanies, newCompany)

import Json exposing (companiesDecoder, newCompanyEncoder)
import Model exposing (NewCompany)
import Msg exposing (Msg(..), NewCompanyMsg(..))
import RemoteData.Http


getCompanies : Cmd Msg
getCompanies =
    RemoteData.Http.get
        "/api/company"
        GetCompaniesCompleted
        companiesDecoder


newCompany : NewCompany -> Cmd Msg
newCompany newCompany =
    RemoteData.Http.post "/api/company/new"
        (NewCompanyMsg << SaveNewCompanyCompleted)
        companiesDecoder
        (newCompanyEncoder newCompany)
