module View.Posts exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (href)
import Html.Events
import Model exposing (Msg(..))
import Model.Post exposing (Post)
import Model.PostsConfig as PC exposing (Change(..), PostsConfig, SortBy(..), filterPosts, sortFromString, sortOptions, sortToCompareFn, sortToString, Field(..), Value(..))
import Time
import Util.Time
import Html.Attributes exposing (class)
import Html.Attributes exposing (id)


{-| Show posts as a HTML [table](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/table)

Relevant local functions:

  - Util.Time.formatDate
  - Util.Time.formatTime
  - Util.Time.formatDuration (once implemented)
  - Util.Time.durationBetween (once implemented)

Relevant library functions:

  - [Html.table](https://package.elm-lang.org/packages/elm/html/latest/Html#table)
  - [Html.tr](https://package.elm-lang.org/packages/elm/html/latest/Html#tr)
  - [Html.th](https://package.elm-lang.org/packages/elm/html/latest/Html#th)
  - [Html.td](https://package.elm-lang.org/packages/elm/html/latest/Html#td)

-}
postTable : PostsConfig -> Time.Posix -> List Post -> Html Msg
postTable postsConfig timePosix posts =
    Html.div
        [ Html.Attributes.style "padding" "20px"
        , Html.Attributes.style "background" "#f5f7fa"
        , Html.Attributes.style "border-radius" "8px"
        ]
        [ Html.table
            [ Html.Attributes.style "width" "100%"
            , Html.Attributes.style "border-collapse" "collapse"
            , Html.Attributes.style "font-family" "sans-serif"
            , Html.Attributes.style "margin-top" "10px"
            ]
            [ Html.thead
                [ Html.Attributes.style "background" "#d9e2ec" ]
                [ Html.tr []
                    [ th "Score"
                    , th "Title"
                    , th "Type"
                    , th "Posted"
                    , th "Link"
                    ]
                ]
            , Html.tbody []
                (List.indexedMap (postRow timePosix) (PC.filterPosts postsConfig posts))
            ]
        ]


th : String -> Html msg
th label =
    Html.th
        [ Html.Attributes.style "padding" "10px"
        , Html.Attributes.style "text-align" "left"
        , Html.Attributes.style "font-weight" "600"
        , Html.Attributes.style "border-bottom" "2px solid #bcccdc"
        ]
        [ Html.text label ]


postRow : Time.Posix -> Int -> Post -> Html Msg
postRow now index post =
    Html.tr
        [ Html.Attributes.style "background" (if modBy 2 index == 0 then "#ffffff" else "#f0f4f8")
        ]
        [ td (String.fromInt post.score)
        , td post.title
        , td post.type_
        , td
            (Util.Time.formatTime Time.utc post.time
                ++ " ("
                ++ Maybe.withDefault "Just now"
                    (Maybe.map Util.Time.formatDuration (Util.Time.durationBetween post.time now))
                ++ ")"
            )
        , Html.td
            [ Html.Attributes.style "padding" "8px"
            , Html.Attributes.style "color" "#1a73e8"
            ]
            [ Html.a
                [ Html.Attributes.href (Maybe.withDefault "" post.url)
                , Html.Attributes.target "_blank"
                ]
                [ Html.text (Maybe.withDefault "" post.url) ]
            ]
        ]


td : String -> Html msg
td content =
    Html.td
        [ Html.Attributes.style "padding" "8px"
        , Html.Attributes.style "border-bottom" "1px solid #d9e2ec"
        ]
        [ Html.text content ]



{-| Show the configuration options for the posts table

Relevant functions:

  - [Html.select](https://package.elm-lang.org/packages/elm/html/latest/Html#select)
  - [Html.option](https://package.elm-lang.org/packages/elm/html/latest/Html#option)
  - [Html.input](https://package.elm-lang.org/packages/elm/html/latest/Html#input)
  - [Html.Attributes.type\_](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#type_)
  - [Html.Attributes.checked](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#checked)
  - [Html.Attributes.selected](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#selected)
  - [Html.Events.onCheck](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onCheck)
  - [Html.Events.onInput](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput)

-}
postsConfigView : PostsConfig -> Html Msg
postsConfigView postsConfig =
    div
        [ Html.Attributes.style "padding" "20px"
        , Html.Attributes.style "background" "#e8eef3"
        , Html.Attributes.style "border-radius" "8px"
        , Html.Attributes.style "margin-bottom" "20px"
        , Html.Attributes.style "font-family" "sans-serif"
        ]
        [ configRow
            [ textLabel "Posts to show:"
            , Html.select
                [ Html.Attributes.style "padding" "6px"
                , Html.Attributes.style "border-radius" "6px"
                , Html.Events.onInput
                    (\value ->
                        ConfigChanged
                            (Change PostsToShow
                                (IntValue (String.toInt value |> Maybe.withDefault postsConfig.postsToShow))
                            )
                    )
                ]
                [ option "10" postsConfig.postsToShow
                , option "25" postsConfig.postsToShow
                , option "50" postsConfig.postsToShow
                ]
            ]
        , configRow
            [ textLabel "Sort by:"
            , Html.select
                [ Html.Attributes.style "padding" "6px"
                , Html.Attributes.style "border-radius" "6px"
                , Html.Events.onInput
                    (\value ->
                        ConfigChanged
                            (Change SortByField
                                (SortValue (PC.sortFromString value |> Maybe.withDefault postsConfig.sortBy))
                            )
                    )
                ]
                [ optionFixed "None"
                , optionFixed "Score"
                , optionFixed "Title"
                , optionFixed "Posted"
                ]
            ]
        , checkbox "Show job posts"
            postsConfig.showJobs
            (\v -> ConfigChanged (Change ShowJobs (BoolValue v)))
        , checkbox "Show text only posts"
            postsConfig.showTextOnly
            (\v -> ConfigChanged (Change ShowTextOnly (BoolValue v)))
        ]


configRow : List (Html msg) -> Html msg
configRow elements =
    div
        [ Html.Attributes.style "margin-bottom" "12px"
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "gap" "12px"
        , Html.Attributes.style "align-items" "center"
        ]
        elements


textLabel : String -> Html msg
textLabel txt =
    Html.label
        [ Html.Attributes.style "font-weight" "600" ]
        [ Html.text txt ]


option : String -> Int -> Html msg
option value current =
    Html.option
        [ Html.Attributes.value value
        , Html.Attributes.selected (String.toInt value == Just current)
        ]
        [ Html.text value ]


optionFixed : String -> Html msg
optionFixed s =
    Html.option [ Html.Attributes.value s ] [ Html.text s ]


checkbox : String -> Bool -> (Bool -> msg) -> Html msg
checkbox txt checked handler =
    div
        [ Html.Attributes.style "margin-bottom" "8px" ]
        [ Html.label []
            [ Html.input
                [ Html.Attributes.type_ "checkbox"
                , Html.Attributes.checked checked
                , Html.Events.onCheck handler
                ]
                []
            , Html.text (" " ++ txt)
            ]
        ]
