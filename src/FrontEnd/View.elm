module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (Company, Model, NewCompany, Route(..))
import Msg exposing (Msg(..), NewCompanyMsg(..))
import RemoteData
import WebData exposing (WebData(..))


view : Model -> Html Msg
view model =
    case model of
        CompanyListRoute { companies } ->
            companyListView companies

        NewCompanyRoute { companies, newCompany } ->
            newCompanyView companies newCompany


newCompanyView : WebData (List Company) -> NewCompany -> Html Msg
newCompanyView companies newCompany =
    templateView
        (Html.form []
            [ h2 [] [ text "New Company" ]
            , div [ class "form-group" ]
                [ label [ for "name" ]
                    [ text "Name" ]
                , input
                    [ id "name"
                    , class "form-control"
                    , type_ "text"
                    , onInput (NewCompanyMsg << NameUpdated)
                    , required True
                    ]
                    []
                ]
            , div [ class "form-group" ]
                [ label [ for "address1" ] [ text "Address Line 1" ]
                , input [ class "form-control", type_ "text", onInput (NewCompanyMsg << Address1Updated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "address2" ] [ text "Address Line 2" ]
                , input [ id "address2", class "form-control", type_ "text", onInput (NewCompanyMsg << Address2Updated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "city" ] [ text "City" ]
                , input [ id "city", class "form-control", type_ "text", onInput (NewCompanyMsg << CityUpdated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "state" ] [ text "State" ]
                , input [ id "state", class "form-control", type_ "text", onInput (NewCompanyMsg << StateUpdated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "zipCode" ] [ text "Zip Code" ]
                , input [ id "zipCode", class "form-control", type_ "text", onInput (NewCompanyMsg << ZipCodeUpdated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "phoneNumber" ] [ text "Phone Number" ]
                , input [ id "phoneNumber", class "form-control", type_ "text", onInput (NewCompanyMsg << PhoneNumberUpdated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "faxNumber" ] [ text "Fax Number" ]
                , input [ id "faxNumber", class "form-control", type_ "text", onInput (NewCompanyMsg << FaxNumberUpdated) ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "category" ] [ text "Category" ]
                , input [ id "category", class "form-control", type_ "text", onInput (NewCompanyMsg << CategoryUpdated) ] []
                ]
            , errorView companies
            , div [ class "card" ]
                [ div [ class "card-body" ]
                    [ button
                        [ type_ "button"
                        , class "btn btn-secondary"
                        , onClick (NewCompanyMsg CancelNewCompanyClicked)
                        , disabled (WebData.isLoading companies)
                        ]
                        [ text "Cancel" ]
                    , text " "
                    , if WebData.isLoading companies then
                        button [ class "btn btn-primary", type_ "button", disabled True ] [ text "Saving..." ]
                      else
                        button [ class "btn btn-primary", type_ "button", onClick (NewCompanyMsg SaveNewCompanyClicked) ] [ text "Save" ]
                    ]
                ]
            ]
        )


errorView : WebData a -> Html msg
errorView webData =
    case WebData.getErrorMessage webData of
        Just errorMessage ->
            div [ class "alert alert-danger", attribute "role" "alert" ]
                [ text errorMessage ]

        Nothing ->
            text ""


companyListView : WebData (List Company) -> Html Msg
companyListView webData =
    case webData of
        WebData.RemoteData RemoteData.NotAsked ->
            templateView empty

        WebData.RemoteData RemoteData.Loading ->
            templateView loading

        WebData.RemoteData (RemoteData.Failure error) ->
            templateView empty

        WebData.RemoteData (RemoteData.Success companies) ->
            templateView (companyTableView companies)

        WebData.FailureWithData error companies ->
            templateView empty

        WebData.Reloading companies ->
            templateView
                (div []
                    [ companyTableView companies
                    , loading
                    ]
                )


companyTableView : List Company -> Html Msg
companyTableView companies =
    if List.isEmpty companies then
        empty
    else
        div []
            [ table [ class "table" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Id" ]
                        , th [] [ text "Name" ]
                        , th [] [ text "Address" ]
                        , th [] [ text "City" ]
                        , th [] [ text "State" ]
                        , th [] [ text "ZipCode" ]
                        , th [] [ text "PhoneNumber" ]
                        , th [] [ text "FaxNumber" ]
                        , th [] [ text "Category" ]
                        , th [] []
                        ]
                    ]
                , tbody [] (companies |> List.map companyRowView)
                ]
            , actionView companies
            ]


companyRowView : Company -> Html Msg
companyRowView company =
    tr []
        [ td [] [ text <| toString company.id ]
        , td [] [ text company.name ]
        , td [] [ text company.address1, br [] [], text company.address2 ]
        , td [] [ text company.city ]
        , td [] [ text company.state ]
        , td [] [ text company.zipCode ]
        , td [] [ text company.phoneNumber ]
        , td [] [ text company.faxNumber ]
        , td [] [ text company.category ]
        , td []
            [ button
                [ class "btn btn-danger btn-sm"
                , type_ "button"
                , onClick (DeleteCompanyClicked company.id)
                ]
                [ text "Delete" ]
            ]
        ]


templateView : Html Msg -> Html Msg
templateView content =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ headerView
            , content
            ]
        ]


headerView : Html Msg
headerView =
    header [] [ h1 [] [ text "Contact Manager" ] ]


actionView : List Company -> Html Msg
actionView companies =
    div [ class "card" ]
        [ div
            [ class "card-body" ]
            [ button
                [ class "btn btn-primary", type_ "button", onClick (NewCompanyClicked companies) ]
                [ text "New Company" ]
            ]
        ]


empty : Html Msg
empty =
    div []
        [ text "No companies found."
        , actionView []
        ]


loading : Html Msg
loading =
    div
        [ class "alert alert-info"
        , style
            [ ( "position", "absolute" )
            , ( "top", "0" )
            , ( "right", "0" )
            , ( "border-radius", "0" )
            , ( "padding", "0.25em 1em" )
            ]
        ]
        [ text "Loading..." ]
