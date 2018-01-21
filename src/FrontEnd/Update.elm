module Update exposing (update)

import Api
import Http
import Model exposing (Company, Model, Route(..))
import Msg exposing (CompanyMsg(..), Msg(..))
import RemoteData
import WebData exposing (WebData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        CompanyListRoute { companies } ->
            updateCompanyListRoute msg companies

        CompanyRoute { companies, company } ->
            case msg of
                CompanyMsg companyMsg ->
                    updateCompanyRoute companyMsg companies company

                _ ->
                    ( CompanyRoute
                        { companies = WebData.error (Http.BadUrl "InvalidSate") companies
                        , company = company
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
                }
            , Cmd.none
            )

        DeleteCompanyClicked companyId ->
            ( CompanyListRoute { companies = WebData.loading companies }
            , Api.deleteCompany companyId
            )

        EditCompanyClicked companyId ->
            ( editCompany companyId companies
            , Cmd.none
            )

        CompanyMsg _ ->
            ( CompanyListRoute { companies = WebData.error (Http.BadUrl "Invalid State") companies }, Cmd.none )


editCompany : Int -> WebData (List Company) -> Route
editCompany companyId companies =
    let
        findCompany companyList =
            companyList
                |> List.filter (\company -> company.id == Model.CompanyId companyId)
                |> List.head
    in
    companies
        |> WebData.toMaybe
        |> Maybe.andThen findCompany
        |> Maybe.map (\company -> CompanyRoute { companies = companies, company = company })
        |> Maybe.withDefault (CompanyListRoute { companies = companies })


updateCompanyRoute : CompanyMsg -> WebData (List Company) -> Company -> ( Route, Cmd Msg )
updateCompanyRoute msg companies company =
    case msg of
        CancelCompanyClicked ->
            ( CompanyListRoute { companies = companies }, Cmd.none )

        SaveCompanyClicked ->
            saveCompany companies company

        NameUpdated value ->
            ( { company | name = value } |> companyRoute companies, Cmd.none )

        Address1Updated value ->
            ( { company | address1 = value } |> companyRoute companies, Cmd.none )

        Address2Updated value ->
            ( { company | address2 = value } |> companyRoute companies, Cmd.none )

        CityUpdated value ->
            ( { company | city = value } |> companyRoute companies, Cmd.none )

        StateUpdated value ->
            ( { company | state = value } |> companyRoute companies, Cmd.none )

        ZipCodeUpdated value ->
            ( { company | zipCode = value } |> companyRoute companies, Cmd.none )

        PhoneNumberUpdated value ->
            ( { company | phoneNumber = value } |> companyRoute companies, Cmd.none )

        FaxNumberUpdated value ->
            ( { company | faxNumber = value } |> companyRoute companies, Cmd.none )

        CategoryUpdated value ->
            ( { company | category = value } |> companyRoute companies, Cmd.none )

        SaveCompanyCompleted webData ->
            case webData of
                RemoteData.Success companies ->
                    ( CompanyListRoute { companies = WebData.RemoteData (RemoteData.Success companies) }, Cmd.none )

                RemoteData.Failure error ->
                    ( companyRoute (WebData.error error companies) company
                    , Cmd.none
                    )

                _ ->
                    ( companyRoute companies company, Cmd.none )


companyRoute : WebData (List Company) -> Company -> Route
companyRoute companies company =
    CompanyRoute { companies = companies, company = company }


saveCompany : WebData (List Company) -> Company -> ( Route, Cmd Msg )
saveCompany companies company =
    ( companyRoute (companies |> WebData.loading) company
    , if Model.isNewCompany company then
        Api.newCompany company
      else
        Api.updateCompany company
    )
