module Api
    exposing
        ( deleteCompany
        , getCompanies
        , newCompany
        , updateCompany
        )

import Json exposing (companiesDecoder, companyEncoder)
import Json.Encode
import Model exposing (Company)
import Msg exposing (CompanyMsg(..), Msg(..))
import RemoteData
import RemoteData.Http
import Task


getCompanies : Cmd Msg
getCompanies =
    getCompaniesTask
        |> Task.perform GetCompaniesCompleted


getCompaniesTask : Task.Task Never (RemoteData.WebData (List Model.Company))
getCompaniesTask =
    RemoteData.Http.getTask
        "/api/company"
        companiesDecoder


newCompany : Company -> Cmd Msg
newCompany newCompany =
    RemoteData.Http.post
        "/api/company/new"
        (CompanyMsg << SaveCompanyCompleted)
        companiesDecoder
        (companyEncoder newCompany)


updateCompany : Company -> Cmd Msg
updateCompany company =
    RemoteData.Http.post
        "/api/company"
        (CompanyMsg << SaveCompanyCompleted)
        companiesDecoder
        (companyEncoder company)


deleteCompany : Int -> Cmd Msg
deleteCompany companyId =
    let
        deleteTask =
            RemoteData.Http.deleteTask
                ("/api/company/" ++ toString companyId)
                Json.Encode.null
    in
    deleteTask
        |> Task.andThen (\_ -> getCompaniesTask)
        |> Task.perform GetCompaniesCompleted
