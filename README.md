# Contests-Engine

## General
The *Contests-Engine* site provides a public REST-API to a tournament management back-end system that handles contests, participants, draws, matches and the like for almost any contest (football championships, tennis trophies, billard tournaments and so on).

The goal of *Contests-Engine* is to let developers of tournament management front-ends (websites, mobile apps, desktop apps, ...) concentrate on the presentation layer of their systems, e.g.
- Fast and simple data entry forms
- Easy definition of a manual draw by dragging around participants on the empty tableau
- Elegant renderings of large groups- or knock-out-tableaus with scrolling and zooming.

*Contests-Engine* in the background then handles tasks like
- Store, update and retrieve all data of the contests
- Randomly fill an incomplete draw or create an entire draw with due regard to special rules like seed lists
- Create all the matches and their dependencies according to the type of the contest (round robin, groups, elimination or double-elimination game, ...)
- Actualize everything whenever a new result is received, e.g. propagate the winner of an elimination game to the next round or group winners to the final group or elimination round
- Distribute points for wins, losses and eventually ties, calculate statistics and rankings

## First version (Minimal Viable Product)
The first version of *Contests-Engine*, which is almost finished, provide minimal functionality for
- Registration and login with username / password for contest managers
- Login for participants to a specific contest with tokens generated for read or write access to the entire contest or only a players own matches
- Creating and editing contests and participants with minimal data needed
- Doing the draw (manually or automatic with or without seed list) and generate all matches
- Edit the match results and actualize the contests state
- Contests type 'Groups' (round robin), no return matches and no sudden death or final groups for the group winners
- Contest type 'Knock-out' (sudden death, elimination game), no match for third place

## Ideas for future Enhancements
See [Issues](https://github.com/florza/contests-engine/issues), label `enhancement`.

## Tools used
*Contest-Engine* is written in Ruby on Rails.

Frontend applications can be developed with any tool that can make REST-API-calls. A first draft of such an application as a proof of concept was developed with Vue.js. Technical details of it can be found at https://github.com/florza/contests-example, a provisional version of the app can be be accessed (without any guarantees for availability or performance!) at https://contests-example.herokuapp.com.

## Basic API requests
This basic set of API-calls is implemented:

|Verb     |Resource                                 |Description|
|---      |---                                      |---|
|`POST`   |`/signup`                                |Registration of a new user
|`POST`   |`/signin`                                |Login
|`DELETE` |`/signin`                                |Logout
|`POST`   |`/refresh`                               |Refresh a timed out token^|
|`GET`    |`/api/v1/contests`                       |Read all contests of the user or the token's contest
|`GET`    |`/api/v1/contests/:id`                   |Read one contest
|`POST`   |`/api/v1/contests`                       |Create a new contest for the actual user
|`PATCH`  |`/api/v1/contests/:id`                   |Update a contest
|`DELETE` |`/api/v1/contests/:id`                   |Delete a contests
|`GET`    |`/api/v1/contests/:id/draw`              |Read an empty tableau structure for the actual number of participants
|`POST`   |`/api/v1/contests/:id/draw`              |Eventually complete, then create and save the draw for a contests
|`DELETE` |`/api/v1/contests/:id/draw`              |Delete the actual draw of a contest
|`GET`    |`/api/v1/contests/:id/participants`      |Read all participants of a contest
|`GET`    |`/api/v1/contests/:id/participants/:id`  |Read one participant
|`POST`   |`/api/v1/contests/:id/participants`      |Create one participant of the contest
|`PATCH`  |`/api/v1/contests/:id/participants/:id`  |Update a participant of the contest
|`DELETE` |`/api/v1/contests/:id/participants/:id`  |Delete a participant of the contest
|`GET`    |`/api/v1/contests/:id/matches/`          |Get all matches of the contest
|`GET`    |`/api/v1/contests/:id/matches/:id`       |Get one match of the contest
|`PATCH`  |`/api/v1/contests/:id/matches/:id`       |Update a match of the contests, usually the match result

A detailled description of these request can be found at [Postman](https://zangas.postman.co/collections/12018474-6cc2cf8e-a6b0-4685-882c-a7858e84fd77?version=latest&workspace=43d87820-5dab-43a5-8916-086b97701eea#dfb3a295-659a-48d7-ab43-d749566e9d59).

An instance of the application and the API is provided at https://contests-example.herokuapp.com to send requests and receive responses with Postman or CURL. However, this installation is also used by the developers sometimes and no guarantee is given on the availability of the app or permanent storage of example data you entered. The app and the database may be overwritten or initialized at any time.

## JSON:API
For request and response formats, *Contests-Engine* implements the JSON:API specification of https://jsonapi.org using the `graphiti` gem. Therefore, the requests can also be modified with orderings, field selections, conditions, sideloads and other things by sending additional query parameters according to the specification. For example:
```HTTP
GET /api/v1/contests/123?include=participants,matches
```
reads the data of an entire contest with all its participants and matches in one request. This is the recommended way to read and refresh contest data after an update request, because you will always receive a consistent image of the contest. Especially an update of a match can lead to a lot of updates of other resources, e.g. succeeding matches, participants rankings or contest state, and if you just refreshed the updated match you would miss many of them!

Another application of a JSON:API feature is the definition of contests and participant tokens as `extra-fields`. They are then not shown in usual responses and are only sent if they are explicitly requested in the query string:
```HTTP
GET /api/v1/contests/123?extra_fields[contests]=token_write,token_read
```
## Contributions
Contributions to this application are very welcome. These may be:
- Comments and answers to the issues and questions
- Propositions for additional features or better solutions
- Pull requests (but please let me know what you are planning to do before you invest too much time!)
- Development of a production-ready front-end application of your own, which would certainly result in many valuable ideas to improve the back-end engine!

## Some recent developments
- Draw with seed list for knock-out and groups contests
- Included some meta information in the standard JSON:API responses
- Defined read-only attributes `contest.has_draw`, `contests.has_started`, `match.result_editable`, `match.result_1_vs_2`, `rmatch.esult_2_vs_1` in the resource layer, to free the client from this logic
- Replaced cookies and csrf token by an access token that is sent to the client in the login request and resent by the client in the authorization header.
- Included a static home page with some basic information
- Changed input/output to JSON:API-format (https://jsonapi.org) using the `Graphiti` gem (https://graphiti.dev)

## Next Steps
See https://github.com/florza/contests-example/issues.

## Local installation
First, make a basic copy from github and install the necessary Ruby Gems. The gemfile states the Ruby version used as 2.7.1. If you use another version and do not want to change it, adapt the entry in `gemfile` to your version before running `bundle install`.

```console
$ git clone https://github.com/florza/contests-engine.git myContestsEngine
$ cd myContestsEngine
$ bundle install
```

The application uses the files `master.key` and `credentials.yml.enc` to store the JWT encryption key. The github repository contains no master key and only an encrypted credentials file which is of no use to you without the key, so you have to initialize these files by yourself:

```console
$ rm config/credentials.yml.enc
$ EDITOR=vim rails credentials:edit
```

In the editor (it can be anyone, not only vim), insert the follwing two lines and save the file:

    jwt:
      encryption_key: yourOwnSecretText

You will then have a new file `master.key` and an encrypted version of `credentials.yml.enc`. If you must later edit this file, you can do that with the command you used above.

It is highly recommended to add `master.key` to your `.gitignore` file, so it will never be sent to a public repository. Save the content of `master.key` to your password manager.

Last, you have to initialize the database. Since there are some problems hidden in earlier migrations files, it is recommended to use setup for this, with the additional advantage that you will also have some sample data automatically installed, which is defined in `db/seeds.rb` and `test/fixtures/*.yml`:

```console
$ rails db:environment:set RAILS_ENV=development
$ rails db:setup
```

At the end, you can run the minispec tests with

```console
$ rails t 2>/dev/null
```
The error output is sent to null because there are lots of deprecation warnings with Rails 6.1 at the moment. There are also some rspec specifications included by the `graphiti` gem, but they are not used yet.
