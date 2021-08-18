FROM ruby:3.0.1

# use a newer version of Node to use Yarn
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

# nodejs: Rails needs a JS runtime
# cmake: required by Rugged, dependency of Pronto
RUN apt-get update -qq \
    && apt-get install -y -qq nodejs cmake

RUN npm install -g yarn

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . /app
