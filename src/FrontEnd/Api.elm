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
import String
import Task


getCompanies : Model.Filter -> Cmd Msg
getCompanies filter =
    getCompaniesTask filter
        |> Task.perform GetCompaniesCompleted


getCompaniesTask : Model.Filter -> Task.Task Never (RemoteData.WebData (List Model.Company))
getCompaniesTask filter =
    let
        phoneFilter =
            if filter.phoneNumber |> String.trim |> String.isEmpty then
                ""
            else
                "?phoneNumber=" ++ filter.phoneNumber

        categoryKey =
            if String.isEmpty phoneFilter then
                "?category="
            else
                "&category="

        categoryFilter =
            filter.category
                |> Maybe.map (\category -> categoryKey ++ toString category)
                |> Maybe.withDefault ""
    in
    RemoteData.Http.getTask
        ("/api/company"
            ++ phoneFilter
            ++ categoryFilter
        )
        companiesDecoder


newCompany : Model.Filter -> Company -> Cmd Msg
newCompany filter newCompany =
    RemoteData.Http.postTask
        "/api/company/new"
        (Json.Decode.succeed ())
        (companyEncoder newCompany)
        |> Task.andThen (\_ -> getCompaniesTask filter)
        |> Task.perform (CompanyMsg << SaveCompanyCompleted)


updateCompany : Model.Filter -> Company -> Cmd Msg
updateCompany filter company =
    RemoteData.Http.postTask
        "/api/company"
        (Json.Decode.succeed ())
        (companyEncoder company)
        |> Task.andThen (\_ -> getCompaniesTask filter)
        |> Task.perform (CompanyMsg << SaveCompanyCompleted)


deleteCompany : Model.Filter -> Int -> Cmd Msg
deleteCompany filter companyId =
    RemoteData.Http.deleteTask
        ("/api/company/" ++ toString companyId)
        Json.Encode.null
        |> Task.andThen (\_ -> getCompaniesTask filter)
        |> Task.perform GetCompaniesCompleted


newCategory : Model.CategoryMode -> Cmd Msg
newCategory categoryMode =
    case categoryMode of
        Model.NewCategory name ->
            RemoteData.Http.post
                "/api/category/new"
                GetCategoriesCompleted
                (Json.Decode.list Json.categoryDecoder)
                (Json.Encode.string name)

        _ ->
            Cmd.none


getCategories : Cmd Msg
getCategories =
    getCategoriesTask
        |> Task.perform GetCategoriesCompleted


getCategoriesTask : Task.Task Never (RemoteData.WebData (List Model.Category))
getCategoriesTask =
    RemoteData.Http.getTask
        "/api/category"
        (Json.Decode.list Json.categoryDecoder)
