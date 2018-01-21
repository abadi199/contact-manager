module Api exposing (deleteCompany, getCompanies, newCompany)

import Json exposing (companiesDecoder, newCompanyEncoder)
import Json.Encode
import Model exposing (NewCompany)
import Msg exposing (Msg(..), NewCompanyMsg(..))
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


newCompany : NewCompany -> Cmd Msg
newCompany newCompany =
    RemoteData.Http.post
        "/api/company/new"
        (NewCompanyMsg << SaveNewCompanyCompleted)
        companiesDecoder
        (newCompanyEncoder newCompany)


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
