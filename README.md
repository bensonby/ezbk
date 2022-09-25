# ezbk

Easy Bookkeeping with accounting principles

## Short Description

- Written with Ruby on Rails
- Full income statement and balanced sheet view of your accounts
- Double Entry Accounting, e.g. Debit \$20 to lunch expense and credit \$20 to cash
- Keyboard shortcuts with transaction autocomplete to quickly repeat a previous transaction
- Current top bar is tailored for Hong Kong people

## Demo

[On Heroku](http://ezbk.herokuapp.com)

## System requirements

- Ruby 2.7.6
- Postgres (`brew install libpq` for Mac)

## Setup

### locally without Docker

```bash
bundle install
chmod u+x bin/rails
bin/rails server
createdb ezbk_development
bin/rails db:migrate
```

IMPORTANT: For development mode, make sure to comment out commands in `Dockerfile` accordingly before building docker image.

```bash
docker build . # add --platform linux/amd64 in M1, add --pull and --no-cache if necessary
docker-compose exec ezbk rake db:create
docker-compose exec ezbk rake db:migrate
docker-compose up
```

## Deployment through docker

```bash
docker-compose stop ezbk
docker-compose rm ezbk
docker-compose build --no-cache ezbk
docker-compose up -d ezbk
```
