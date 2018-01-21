module Update exposing (update)

import Api
import Http
import Model exposing (Category, Company, Model, Route(..))
import Msg exposing (CompanyMsg(..), Msg(..))
import RemoteData
import String
import WebData exposing (WebData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        CompanyListRoute { companies } ->
            updateCompanyListRoute msg companies

        CompanyRoute { companies, company, categories, categoryMode } ->
            case msg of
                CompanyMsg companyMsg ->
                    updateCompanyRoute companyMsg companies categories categoryMode company

                _ ->
                    ( CompanyRoute
                        { companies = WebData.error (Http.BadUrl "InvalidSate") companies
                        , company = company
                        , categories = categories
                        , categoryMode = Model.SelectCategory
                        }
                    , Cmd.none
                    )


updateCompanyListRoute : Msg -> WebData (List Company) -> ( Route, Cmd Msg )
updateCompanyListRoute msg companies =
    case msg of
        NoOp ->
            ( CompanyListRoute { companies = companies }, Cmd.none )

        GetCompaniesCompleted webData ->
            ( CompanyListRoute { companies = WebData.RemoteData webData }, Cmd.none )

        NewCompanyClicked companies ->
            ( CompanyRoute
                { companies = WebData.RemoteData (RemoteData.Success companies)
                , company = Model.newCompany
                , categories = []
                , categoryMode = Model.SelectCategory
                }
            , Api.getCategories
            )

        DeleteCompanyClicked companyId ->
            ( CompanyListRoute { companies = WebData.loading companies }
            , Api.deleteCompany companyId
            )

        EditCompanyClicked companyId ->
            ( editCompany companyId companies
            , Api.getCategories
            )

        CompanyMsg _ ->
            ( CompanyListRoute { companies = WebData.error (Http.BadUrl "Invalid State") companies }, Cmd.none )


editCompany : Int -> WebData (List Company) -> Route
editCompany companyId companies =
    let
        findCompany companyList =
            companyList
                |> List.filter (\company -> company.id == Just companyId)
                |> List.head
    in
    companies
        |> WebData.toMaybe
        |> Maybe.andThen findCompany
        |> Maybe.map (\company -> CompanyRoute { companies = companies, company = company, categories = [], categoryMode = Model.SelectCategory })
        |> Maybe.withDefault (CompanyListRoute { companies = companies })


updateCompanyRoute : CompanyMsg -> WebData (List Company) -> List Category -> Model.CategoryMode -> Company -> ( Route, Cmd Msg )
updateCompanyRoute msg companies categories categoryMode company =
    case msg of
        CancelCompanyClicked ->
            ( CompanyListRoute { companies = companies }, Cmd.none )

        SaveCompanyClicked ->
            saveCompany companies categories company

        NameUpdated value ->
            ( { company | name = value } |> companyRoute companies categories, Cmd.none )

        Address1Updated value ->
            ( { company | address1 = value } |> companyRoute companies categories, Cmd.none )

        Address2Updated value ->
            ( { company | address2 = value } |> companyRoute companies categories, Cmd.none )

        CityUpdated value ->
            ( { company | city = value } |> companyRoute companies categories, Cmd.none )

        StateUpdated value ->
            ( { company | state = value } |> companyRoute companies categories, Cmd.none )

        ZipCodeUpdated value ->
            ( { company | zipCode = value } |> companyRoute companies categories, Cmd.none )

        PhoneNumberUpdated value ->
            ( { company | phoneNumber = value } |> companyRoute companies categories, Cmd.none )

        FaxNumberUpdated value ->
            ( { company | faxNumber = value } |> companyRoute companies categories, Cmd.none )

        CategoryUpdated value ->
            ( { company | category = value } |> companyRoute companies categories, Cmd.none )

        SaveCompanyCompleted webData ->
            case webData of
                RemoteData.Success companies ->
                    ( CompanyListRoute { companies = WebData.RemoteData (RemoteData.Success companies) }, Cmd.none )

                RemoteData.Failure error ->
                    ( companyRoute (WebData.error error companies) categories company
                    , Cmd.none
                    )

                _ ->
                    ( companyRoute companies categories company, Cmd.none )

        NewCategoryClicked ->
            ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.NewCategory "" }
            , Cmd.none
            )

        CategoryNameUpdated name ->
            case categoryMode of
                Model.SelectCategory ->
                    ( companyRoute companies categories company
                    , Cmd.none
                    )

                Model.NewCategory _ ->
                    ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.NewCategory name }
                    , Cmd.none
                    )

        SaveNewCategoryClicked ->
            ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = categoryMode }
            , Api.newCategory categoryMode
            )

        SaveEditCategoryClicked ->
            ( CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = categoryMode }
            , Cmd.none
            )

        CancelCategoryClicked ->
            ( companyRoute companies categories company, Cmd.none )

        GetCategoriesCompleted webData ->
            case webData of
                RemoteData.Success newCategories ->
                    ( companyRoute companies newCategories { company | category = newCategories |> List.head }, Cmd.none )

                RemoteData.Failure error ->
                    ( companyRoute (WebData.error error companies) categories company, Cmd.none )

                _ ->
                    ( companyRoute companies categories company, Cmd.none )


companyRoute : WebData (List Company) -> List Category -> Company -> Route
companyRoute companies categories company =
    CompanyRoute { companies = companies, company = company, categories = categories, categoryMode = Model.SelectCategory }


saveCompany : WebData (List Company) -> List Category -> Company -> ( Route, Cmd Msg )
saveCompany companies categories company =
    if String.trim company.name == "" then
        ( companyRoute (companies |> WebData.error (Http.BadUrl "Name is required")) categories company, Cmd.none )
    else
        ( companyRoute (companies |> WebData.loading) categories company
        , company.id
            |> Maybe.map (always (Api.updateCompany company))
            |> Maybe.withDefault (Api.newCompany company)
        )
