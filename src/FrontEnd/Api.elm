module Api
    exposing
        ( deleteCompany
        , getCategories
        , getCompanies
        , newCategory
        , newCompany
        , updateCompany
        )

import Json exposing (companiesDecoder, companyEncoder)
import Json.Decode
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


newCategory : Model.CategoryMode -> Cmd Msg
newCategory categoryMode =
    case categoryMode of
        Model.NewCategory name ->
            RemoteData.Http.post
                "/api/category/new"
                (CompanyMsg << GetCategoriesCompleted)
                (Json.Decode.list Json.categoryDecoder)
                (Json.Encode.string name)

        _ ->
            Cmd.none


getCategories : Cmd Msg
getCategories =
    getCategoriesTask
        |> Task.perform (CompanyMsg << GetCategoriesCompleted)


getCategoriesTask : Task.Task Never (RemoteData.WebData (List Model.Category))
getCategoriesTask =
    RemoteData.Http.getTask
        "/api/category"
        (Json.Decode.list Json.categoryDecoder)
