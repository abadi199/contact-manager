port module Update exposing (update)

import Api
import Http
import Model exposing (Category, Company, Model, Route(..))
import Msg exposing (CompanyMsg(..), Msg(..))
import RemoteData
import String
import WebData exposing (WebData)


port confirm : { question : String, domId : String } -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        CompanyListRoute data ->
            updateCompanyListRoute msg data

        CompanyRoute ({ companies, company, categories, categoryMode, filter } as data) ->
            case msg of
                CompanyMsg companyMsg ->
                    updateCompanyRoute companyMsg data

                GetCategoriesCompleted webData ->
                    case webData of
                        RemoteData.Success newCategories ->
                            let
                                setToFirstCompanyIfEmpty company =
                                    case company.category of
                                        Nothing ->
                                            { company | category = newCategories |> List.head }

                                        Just _ ->
                                            company
                            in
                            ( companyRoute companies newCategories filter (setToFirstCompanyIfEmpty company), Cmd.none )

                        RemoteData.Failure error ->
                            ( companyRoute (WebData.error error companies) categories filter company, Cmd.none )

                        _ ->
                            ( companyRoute companies categories filter company, Cmd.none )

                _ ->
                    ( CompanyRoute
                        { companies = WebData.error (Http.BadUrl "InvalidSate") companies
                        , company = company
                        , categories = categories
                        , categoryMode = Model.SelectCategory
                        , filter = filter
                        }
                    , Cmd.none
                    )


updateCompanyListRoute : Msg -> Model.CompanyListRouteData -> ( Route, Cmd Msg )
updateCompanyListRoute msg { companies, categories, filter } =
    case msg of
        NoOp ->
            ( CompanyListRoute { companies = companies, categories = categories, filter = filter }, Cmd.none )

        GetCompaniesCompleted webData ->
            ( CompanyListRoute { companies = WebData.RemoteData webData, categories = categories, filter = filter }, Cmd.none )

        NewCompanyClicked companies ->
            ( CompanyRoute
                { companies = WebData.RemoteData (RemoteData.Success companies)
                , company = Model.newCompany
                , categories = []
                , categoryMode = Model.SelectCategory
                , filter = filter
                }
            , Api.getCategories
            )

        EditCompanyClicked companyId ->
            ( editCompany companyId companies categories filter
            , Api.getCategories
            )

        CompanyMsg _ ->
            ( CompanyListRoute { companies = WebData.error (Http.BadUrl "Invalid State") companies, categories = categories, filter = filter }, Cmd.none )

        GetCategoriesCompleted webData ->
            case webData of
                RemoteData.Success newCategories ->
                    ( CompanyListRoute { companies = companies, categories = newCategories, filter = filter }, Cmd.none )

                RemoteData.Failure error ->
                    ( CompanyListRoute { companies = companies |> WebData.error error, categories = [], filter = filter }, Cmd.none )

                _ ->
                    ( CompanyListRoute { companies = companies, categories = [], filter = filter }, Cmd.none )

        SearchByPhoneUpdated value ->
            ( CompanyListRoute { companies = companies, categories = categories, filter = { filter | phoneNumber = value } }
            , Cmd.none
            )

        SearchByCategoryUpdated value ->
            ( CompanyListRoute { companies = companies, categories = categories, filter = { filter | category = value } }
            , Cmd.none
            )

        SearchClicked ->
            ( CompanyListRoute { companies = WebData.loading companies, categories = categories, filter = filter }
            , Api.getCompanies filter
            )

        ClearFilterClicked ->
            ( CompanyListRoute { companies = WebData.loading companies, categories = categories, filter = Model.emptyFilter }
            , Api.getCompanies Model.emptyFilter
            )

        DeleteCompanyConfirmed companyId ->
            ( CompanyListRoute { companies = WebData.loading companies, categories = categories, filter = filter }
            , Api.deleteCompany filter companyId
            )

        DeleteCompanyClicked companyId ->
            ( CompanyListRoute { companies = companies, categories = categories, filter = filter }
            , confirm { question = "Are you sure you want to delete the company?", domId = "deleteButton" ++ toString companyId }
            )


editCompany : Int -> WebData (List Company) -> List Category -> Model.Filter -> Route
editCompany companyId companies categories filter =
    let
        findCompany companyList =
            companyList
                |> List.filter (\company -> company.id == Just companyId)
                |> List.head
    in
    companies
        |> WebData.toMaybe
        |> Maybe.andThen findCompany
        |> Maybe.map (\company -> CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.SelectCategory, filter = filter })
        |> Maybe.withDefault (CompanyListRoute { companies = companies, categories = categories, filter = filter })


updateCompanyRoute : CompanyMsg -> Model.CompanyRouteData -> ( Route, Cmd Msg )
updateCompanyRoute msg ({ companies, categories, categoryMode, company, filter } as data) =
    case msg of
        CancelCompanyClicked ->
            ( CompanyListRoute
                { companies = companies
                , categories = categories
                , filter = Model.emptyFilter
                }
            , Cmd.none
            )

        SaveCompanyClicked ->
            saveCompany companies categories filter company

        NameUpdated value ->
            ( { company | name = value } |> companyRoute companies categories filter, Cmd.none )

        Address1Updated value ->
            ( { company | address1 = value } |> companyRoute companies categories filter, Cmd.none )

        Address2Updated value ->
            ( { company | address2 = value } |> companyRoute companies categories filter, Cmd.none )

        CityUpdated value ->
            ( { company | city = value } |> companyRoute companies categories filter, Cmd.none )

        StateUpdated value ->
            ( { company | state = value } |> companyRoute companies categories filter, Cmd.none )

        ZipCodeUpdated value ->
            ( { company | zipCode = value } |> companyRoute companies categories filter, Cmd.none )

        PhoneNumberUpdated value ->
            ( { company | phoneNumber = value } |> companyRoute companies categories filter, Cmd.none )

        FaxNumberUpdated value ->
            ( { company | faxNumber = value } |> companyRoute companies categories filter, Cmd.none )

        CategoryUpdated value ->
            ( { company | category = value } |> companyRoute companies categories filter, Cmd.none )

        SaveCompanyCompleted webData ->
            case webData of
                RemoteData.Success companies ->
                    ( CompanyListRoute { companies = WebData.RemoteData (RemoteData.Success companies), categories = categories, filter = filter }, Cmd.none )

                RemoteData.Failure error ->
                    ( companyRoute (WebData.error error companies) categories filter company
                    , Cmd.none
                    )

                _ ->
                    ( companyRoute companies categories filter company, Cmd.none )

        NewCategoryClicked ->
            ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.NewCategory "", filter = filter }
            , Cmd.none
            )

        CategoryNameUpdated name ->
            case categoryMode of
                Model.SelectCategory ->
                    ( companyRoute companies categories filter company
                    , Cmd.none
                    )

                Model.NewCategory _ ->
                    ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.NewCategory name, filter = filter }
                    , Cmd.none
                    )

        SaveNewCategoryClicked ->
            ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = categoryMode, filter = filter }
            , Api.newCategory categoryMode
            )

        SaveEditCategoryClicked ->
            ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = categoryMode, filter = filter }
            , Cmd.none
            )

        CancelCategoryClicked ->
            ( companyRoute companies categories filter company, Cmd.none )


companyRoute : WebData (List Company) -> List Category -> Model.Filter -> Company -> Route
companyRoute companies categories filter company =
    CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.SelectCategory, filter = filter }


saveCompany : WebData (List Company) -> List Category -> Model.Filter -> Company -> ( Route, Cmd Msg )
saveCompany companies categories filter company =
    if String.trim company.name == "" then
        ( companyRoute (companies |> WebData.error (Http.BadUrl "Name is required")) categories filter company, Cmd.none )
    else
        ( companyRoute (companies |> WebData.loading) categories filter company
        , company.id
            |> Maybe.map (always (Api.updateCompany filter company))
            |> Maybe.withDefault (Api.newCompany filter company)
        )
