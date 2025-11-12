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
    Html.div []
        [Html.table []
            [Html.thead []
              [Html.tr []
                  [ Html.th [] [ Html.text "Score" ]
                  , Html.th [] [ Html.text "Title" ]
                  , Html.th [] [ Html.text "Type" ]
                  , Html.th [] [ Html.text "Posted date" ]
                  , Html.th [] [ Html.text "Link" ]
                  ]
              ],
            Html.tbody []
            (List.map
                (\post ->
                    Html.tr []
                        [ Html.td [ class "post-score" ] [ Html.text (String.fromInt post.score) ]
                        , Html.td [ class "post-title" ] [ Html.text post.title ]
                        , Html.td [ class "post-type" ] [ Html.text post.type_ ]
                        , Html.td [ class "post-time" ]
                            [Html.text
                                ( Util.Time.formatTime Time.utc post.time
                                    ++ " ("
                                    ++ (Maybe.withDefault "Just now"
                                        (Maybe.map
                                            Util.Time.formatDuration
                                            (Util.Time.durationBetween post.time timePosix)
                                        )
                                       )
                                    ++ ")"
                                )
                            ]
                        , Html.td [ class "post-url" ]
                            [ Html.a
                                [ Html.Attributes.href (Maybe.withDefault "" post.url)
                                , Html.Attributes.target "_blank"
                                ]
                                [ Html.text (Maybe.withDefault "" post.url) ]
                            ]
                        ]
                )
                (PC.filterPosts postsConfig posts)
            )
            ]
        ]


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
    div []
    [
        Html.label [] [ Html.text "Posts per page: " ],
        Html.select
        [id "select-posts-per-page",
         Html.Events.onInput (\value -> ConfigChanged (Change PostsToShow (IntValue (String.toInt value |> Maybe.withDefault postsConfig.postsToShow))))
        ]
        [
            Html.option [ Html.Attributes.value "10" ] [Html.text "10"],
            Html.option [ Html.Attributes.value "25" ] [Html.text "25"],
            Html.option [ Html.Attributes.value "50" ] [Html.text "50"]
        ],
        Html.select
        [id "select-sort-by",
         Html.Events.onInput (\value -> ConfigChanged (Change SortByField (SortValue (PC.sortFromString value |> Maybe.withDefault postsConfig.sortBy))))
        ]
        [
            Html.option [] [Html.text "None"],
            Html.option [] [Html.text "Score"],
            Html.option [] [Html.text "Title"],
            Html.option [] [Html.text "Posted"]
        ],
        Html.label []
            [ Html.input
                [ Html.Attributes.type_ "checkbox"
                , Html.Attributes.checked postsConfig.showJobs
                , Html.Attributes.id "checkbox-show-job-posts"
                , Html.Events.onCheck (\value -> ConfigChanged (Change ShowJobs (BoolValue value)))
                ]
                []
            , Html.text " Show job posts"
            ],
        Html.label []
            [ Html.input
                [ Html.Attributes.type_ "checkbox"
                , Html.Attributes.checked postsConfig.showTextOnly
                , Html.Attributes.id "checkbox-show-text-only-posts"
                , Html.Events.onCheck (\value -> ConfigChanged (Change ShowTextOnly (BoolValue value)))
                ]
                []
            , Html.text " Show text only posts"
            ]
    ]