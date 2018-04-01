# Chef'd Mini Project

## Overview

  This simple set of ruby files will fetch a set of tweets from the Twitter public search API, parse them, and store information about the tweets, users, and hashtags in a postgres database for later analysis. There are three basic components to the code: fetching, parsing, and storage

### Fetching

  The `twitter` ruby gem is used to fetch records from the public Twitter API. Currently the search term is hardcoded for convenience. The `since_id` is fetched from storage at startup and updated as API calls are made. So if the script stops for whatever reason, it's able to pick up where it left off. Right now, for simplicity, the fetching code is just polling the Twitter API every second or so to check for new records. These records are fed into a queue where they can be handled one of the parsing threads.

### Parsing

  Most of the parsing of the raw API response is done for us by the `twitter` gem. It takes care of getting the tweet text, user id, hashtags, etc. and making convenient accessor methods to get them. The main job of the parsing threads here is to transform the tweet into a format suitable for insertion into our particular database schema. To this end, it takes each records and packs the relevent tweet, user, and hashtag info into an object which is pushed onto a queue for later use by the storage mechanism.

### Storage

  Storage is pretty simple in this case. Just pop the data off the queue provided by the parser and try to insert the records in a transaction. Each record ought to result in 1 new tweet record, 0 or 1 new user rows, and 0 to N new hashtag rows.


## Schema

  Postgres is being used as the persistent data store. The three main tables of interest are the `tweets`, `users`, and `hashtags` tables. The schema for each can be seen in `migrations/001_create_models.rb`.

## Setup

  - install ruby 2.5.0 (e.g. with [RVM](https://rvm.io/))
  - install postgres
  - create a [twitter app](https://developer.twitter.com/)
  - setup following environment variables in a `.env` file
    - `DATABASE_URL`
    - `TWITTER_CONSUMER_KEY`
    - `TWITTER_CONSUMER_SECRET`
    - `TWITTER_ACCESS_TOKEN`
    - `TWITTER_ACCESS_SECRET`
  - `bundle`
  - `bin/rake db:create`
  - `bin/rake db:migrate`


## Running It
  - `ruby main.rb`

  The script will run in an infinite loop polling/parsing/storing until the user interrupts it or an error is raised.
