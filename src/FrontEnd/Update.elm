module Update exposing (update)

import Api
import Http
import Model exposing (Company, Model, NewCompany, Route(..))
import Msg exposing (Msg(..), NewCompanyMsg(..))
import RemoteData
import WebData exposing (WebData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        CompanyListRoute { companies } ->
            updateCompanyListRoute msg companies

        NewCompanyRoute { companies, newCompany } ->
            case msg of
                NewCompanyMsg newCompanyMsg ->
                    updateNewCompanyRoute newCompanyMsg companies newCompany

                _ ->
                    ( NewCompanyRoute
                        { companies = WebData.error (Http.BadUrl "InvalidSate") companies
                        , newCompany = newCompany
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
            ( NewCompanyRoute
                { companies = WebData.RemoteData (RemoteData.Success companies)
                , newCompany = Model.newCompany
                }
            , Cmd.none
            )

        DeleteCompanyClicked companyId ->
            ( CompanyListRoute { companies = WebData.loading companies }
            , Api.deleteCompany companyId
            )

        NewCompanyMsg newCompanyMsg ->
            ( CompanyListRoute { companies = WebData.error (Http.BadUrl "Invalid State") companies }, Cmd.none )


updateNewCompanyRoute : NewCompanyMsg -> WebData (List Company) -> NewCompany -> ( Route, Cmd Msg )
updateNewCompanyRoute msg companies newCompany =
    case msg of
        CancelNewCompanyClicked ->
            ( CompanyListRoute { companies = companies }, Cmd.none )

        SaveNewCompanyClicked ->
            saveNewCompany companies newCompany

        NameUpdated value ->
            ( { newCompany | name = value } |> newCompanyRoute companies, Cmd.none )

        Address1Updated value ->
            ( { newCompany | address1 = value } |> newCompanyRoute companies, Cmd.none )

        Address2Updated value ->
            ( { newCompany | address2 = value } |> newCompanyRoute companies, Cmd.none )

        CityUpdated value ->
            ( { newCompany | city = value } |> newCompanyRoute companies, Cmd.none )

        StateUpdated value ->
            ( { newCompany | state = value } |> newCompanyRoute companies, Cmd.none )

        ZipCodeUpdated value ->
            ( { newCompany | zipCode = value } |> newCompanyRoute companies, Cmd.none )

        PhoneNumberUpdated value ->
            ( { newCompany | phoneNumber = value } |> newCompanyRoute companies, Cmd.none )

        FaxNumberUpdated value ->
            ( { newCompany | faxNumber = value } |> newCompanyRoute companies, Cmd.none )

        CategoryUpdated value ->
            ( { newCompany | category = value } |> newCompanyRoute companies, Cmd.none )

        SaveNewCompanyCompleted webData ->
            case webData of
                RemoteData.Success companies ->
                    ( CompanyListRoute { companies = WebData.RemoteData (RemoteData.Success companies) }, Cmd.none )

                RemoteData.Failure error ->
                    ( newCompanyRoute (WebData.error error companies) newCompany
                    , Cmd.none
                    )

                _ ->
                    ( newCompanyRoute companies newCompany, Cmd.none )


newCompanyRoute : WebData (List Company) -> NewCompany -> Route
newCompanyRoute companies newCompany =
    NewCompanyRoute { companies = companies, newCompany = newCompany }


saveNewCompany : WebData (List Company) -> NewCompany -> ( Route, Cmd Msg )
saveNewCompany companies newCompany =
    ( newCompanyRoute (companies |> WebData.loading) newCompany
    , Api.newCompany newCompany
    )
