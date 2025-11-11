module Model.PostsConfig exposing (Change(..), PostsConfig, SortBy(..), applyChanges, defaultConfig, filterPosts, sortFromString, sortOptions, sortToCompareFn, sortToString)

import Html.Attributes exposing (scope)
import Model.Post exposing (Post)
import Time exposing (millisToPosix)


type SortBy
    = Score
    | Title
    | Posted
    | None


sortOptions : List SortBy
sortOptions =
    [ Score, Title, Posted, None ]


sortToString : SortBy -> String
sortToString sort =
    case sort of
        Score ->
            "Score"

        Title ->
            "Title"

        Posted ->
            "Posted"

        None ->
            "None"


{-|

    sortFromString "Score" --> Just Score

    sortFromString "Invalid" --> Nothing

    sortFromString "Title" --> Just Title

-}
sortFromString : String -> Maybe SortBy
sortFromString str =
    case str of
        "Score" -> Just Score
        "Title" -> Just Title
        _ -> Nothing


sortToCompareFn : SortBy -> (Post -> Post -> Order)
sortToCompareFn sort =
    case sort of
        Score ->
            \postA postB -> compare postB.score postA.score

        Title ->
            \postA postB -> compare postA.title postB.title

        Posted ->
            \postA postB -> compare (Time.posixToMillis postB.time) (Time.posixToMillis postA.time)

        None ->
            \_ _ -> EQ


type alias PostsConfig =
    { postsToFetch : Int
    , postsToShow : Int
    , sortBy : SortBy
    , showJobs : Bool
    , showTextOnly : Bool
    }


defaultConfig : PostsConfig
defaultConfig =
    PostsConfig 50 10 None False True


{-| A type that describes what option changed and how
-}
type Field
    = PostsToFetch
    | PostsToShow
    | SortByField
    | ShowJobs
    | ShowTextOnly
type Value
    = IntValue Int
    | BoolValue Bool
    | SortValue SortBy
type Change = Change Field Value


{-| Given a change and the current configuration, return a new configuration with the changes applied
-}
applyChanges : Change -> PostsConfig -> PostsConfig
applyChanges change postsConfig =
    case change of
        Change field value ->
            case (field, value) of
                (PostsToFetch, IntValue n) -> { postsConfig | postsToFetch = n }
                (PostsToShow, IntValue n) -> { postsConfig | postsToShow = n }
                (ShowJobs, BoolValue b) -> { postsConfig | showJobs = b }
                (ShowTextOnly, BoolValue b) -> { postsConfig | showTextOnly = b }
                (SortByField, SortValue s) -> { postsConfig | sortBy = s }
                _ -> postsConfig


{-| Given the configuration and a list of posts, return the relevant subset of posts according to the configuration

Relevant local functions:

  - sortToCompareFn

Relevant library functions:

  - List.sortWith

-}

filterPosts : PostsConfig -> List Post -> List Post
filterPosts config posts =
    posts
    |> List.filter (\post -> not config.showTextOnly || post.type_ == "text")
    |> List.filter (\post -> config.showJobs || post.type_ /= "jobs")
    |> List.sortWith (sortToCompareFn config.sortBy)
    |> List.take config.postsToShow