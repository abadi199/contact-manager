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
        (div []
            [ h2 [] [ text "New Company" ]
            , div []
                [ label []
                    [ text "Name"
                    , input
                        [ type_ "text"
                        , onInput (NewCompanyMsg << NameUpdated)
                        , required True
                        ]
                        []
                    ]
                ]
            , div []
                [ label []
                    [ text "Address Line 1"
                    , input [ type_ "text", onInput (NewCompanyMsg << Address1Updated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "Address Line 2"
                    , input [ type_ "text", onInput (NewCompanyMsg << Address2Updated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "City"
                    , input [ type_ "text", onInput (NewCompanyMsg << CityUpdated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "State"
                    , input [ type_ "text", onInput (NewCompanyMsg << StateUpdated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "Zip Code"
                    , input [ type_ "text", onInput (NewCompanyMsg << ZipCodeUpdated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "Phone Number"
                    , input [ type_ "text", onInput (NewCompanyMsg << PhoneNumberUpdated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "Fax Number"
                    , input [ type_ "text", onInput (NewCompanyMsg << FaxNumberUpdated) ] []
                    ]
                ]
            , div []
                [ label []
                    [ text "Category"
                    , input [ type_ "text", onInput (NewCompanyMsg << CategoryUpdated) ] []
                    ]
                ]
            , errorView companies
            , button
                [ type_ "button"
                , onClick (NewCompanyMsg CancelNewCompanyClicked)
                , disabled (WebData.isLoading companies)
                ]
                [ text "Cancel" ]
            , if WebData.isLoading companies then
                button [ type_ "button", disabled True ] [ text "Saving..." ]
              else
                button [ type_ "button", onClick (NewCompanyMsg SaveNewCompanyClicked) ] [ text "Save" ]
            ]
        )


errorView : WebData a -> Html msg
errorView webData =
    if WebData.isFailure webData then
        div [ class "alert alert-error" ] [ text "Unknown error has occured" ]
    else
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
            templateView empty

        WebData.FailureWithData error companies ->
            templateView empty

        WebData.Reloading companies ->
            templateView empty


templateView : Html Msg -> Html Msg
templateView content =
    div []
        [ headerView
        , content
        ]


headerView : Html Msg
headerView =
    header [] [ h1 [] [ text "Contact Manager" ] ]


actionView : List Company -> Html Msg
actionView companies =
    div []
        [ button
            [ type_ "button", onClick (NewCompanyClicked companies) ]
            [ text "New Company" ]
        ]


empty : Html Msg
empty =
    div []
        [ actionView []
        , text "No companies found."
        ]


loading : Html Msg
loading =
    text "Loading..."
