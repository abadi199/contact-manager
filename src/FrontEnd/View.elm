module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Model exposing (Category, Company, Model, Route(..))
import Msg exposing (CompanyMsg(..), Msg(..))
import RemoteData
import WebData exposing (WebData(..))


view : Model -> Html Msg
view model =
    case model of
        CompanyListRoute { companies } ->
            companyListView companies

        CompanyRoute { companies, categories, company, categoryMode } ->
            companyForm companies categories categoryMode company


companyForm : WebData (List Company) -> List Category -> Model.CategoryMode -> Company -> Html Msg
companyForm companies categories categoryMode company =
    templateView
        (Html.form []
            [ h2 []
                [ if Model.isNewCompany company then
                    text "New Company"
                  else
                    text "Edit Company"
                ]
            , div [ class "form-group" ]
                [ label [ for "name" ] [ text "Name" ]
                , input [ id "name", class "form-control", type_ "text", onInput (CompanyMsg << NameUpdated), required True, value company.name ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "address1" ] [ text "Address Line 1" ]
                , input [ class "form-control", type_ "text", onInput (CompanyMsg << Address1Updated), value company.address1 ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "address2" ] [ text "Address Line 2" ]
                , input [ id "address2", class "form-control", type_ "text", onInput (CompanyMsg << Address2Updated), value company.address2, value company.address2 ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "city" ] [ text "City" ]
                , input [ id "city", class "form-control", type_ "text", onInput (CompanyMsg << CityUpdated), value company.city ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "state" ] [ text "State" ]
                , input [ id "state", class "form-control", type_ "text", onInput (CompanyMsg << StateUpdated), value company.state ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "zipCode" ] [ text "Zip Code" ]
                , input [ id "zipCode", class "form-control", type_ "text", onInput (CompanyMsg << ZipCodeUpdated), value company.zipCode ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "phoneNumber" ] [ text "Phone Number" ]
                , input [ id "phoneNumber", class "form-control", type_ "text", onInput (CompanyMsg << PhoneNumberUpdated), value company.phoneNumber ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "faxNumber" ] [ text "Fax Number" ]
                , input [ id "faxNumber", class "form-control", type_ "text", onInput (CompanyMsg << FaxNumberUpdated), value company.faxNumber ] []
                ]
            , div [ class "form-group" ]
                [ label [ for "category" ] [ text "Category" ]
                , categoryDropdown company categories categoryMode
                ]
            , errorView companies
            , div [ class "card" ]
                [ div [ class "card-body" ]
                    [ button
                        [ type_ "button"
                        , class "btn btn-secondary"
                        , onClick (CompanyMsg CancelCompanyClicked)
                        , disabled (WebData.isLoading companies)
                        ]
                        [ text "Cancel" ]
                    , text " "
                    , if WebData.isLoading companies then
                        button [ class "btn btn-primary", type_ "button", disabled True ] [ text "Saving..." ]
                      else
                        button [ class "btn btn-primary", type_ "button", onClick (CompanyMsg SaveCompanyClicked) ] [ text "Save" ]
                    ]
                ]
            ]
        )


categoryDropdown : Company -> List Category -> Model.CategoryMode -> Html Msg
categoryDropdown company categories categoryMode =
    let
        options =
            categories
                |> List.map (\category -> option [ value category, selected (category == company.category) ] [ text category ])
    in
    case categoryMode of
        Model.SelectCategory ->
            div []
                [ select [ style [ ( "margin-bottom", "0.5em" ) ], id "category", class "form-control", on "change" (Json.Decode.map (CompanyMsg << CategoryUpdated) targetValue) ] options
                , button [ class "btn", type_ "button", onClick (CompanyMsg NewCategoryClicked) ] [ text "New" ]
                ]

        Model.NewCategory name ->
            div []
                [ input [ id "category", class "form-control", value name, onInput (CompanyMsg << CategoryNameUpdated), style [ ( "margin-bottom", "0.5em" ) ] ] []
                , button [ type_ "button", class "btn btn-secondary", onClick (CompanyMsg CancelCategoryClicked) ] [ text "Cancel" ]
                , text " "
                , button [ type_ "button", class "btn btn-primary", onClick (CompanyMsg SaveNewCategoryClicked) ] [ text "Save" ]
                ]


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
    let
        actionButtons id =
            td []
                [ button
                    [ class "btn btn-danger btn-sm"
                    , type_ "button"
                    , onClick (DeleteCompanyClicked id)
                    ]
                    [ text "Delete" ]
                , text " "
                , button
                    [ class "btn btn-secondary btn-sm"
                    , type_ "button"
                    , onClick (EditCompanyClicked id)
                    ]
                    [ text "Edit" ]
                ]
    in
    tr []
        [ td [] [ text <| Maybe.withDefault "" <| Maybe.map toString <| Model.companyId <| company ]
        , td [] [ text company.name ]
        , td [] [ text company.address1, br [] [], text company.address2 ]
        , td [] [ text company.city ]
        , td [] [ text company.state ]
        , td [] [ text company.zipCode ]
        , td [] [ text company.phoneNumber ]
        , td [] [ text company.faxNumber ]
        , td [] [ text company.category ]
        , company
            |> Model.companyId
            |> Maybe.map actionButtons
            |> Maybe.withDefault (text "")
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
