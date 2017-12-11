# This file is supposed to be readily used for production
# Please make the changes accordingly if for development
FROM ruby:2.2.8

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y nodejs postgresql-client vim --no-install-recommends && rm -rf /var/lib/apt/lists/*

# uncomment below line if for development
ENV RAILS_ENV production

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

# If for development,
# comment below two and uncomment RUN bundle install
RUN bundle config --global frozen 1
RUN bundle install --without development test
# RUN bundle install

COPY . /usr/src/app
WORKDIR /usr/src/app
RUN bundle exec rake DATABASE_URL=postgresql:does_not_exist assets:precompile

EXPOSE 3000
