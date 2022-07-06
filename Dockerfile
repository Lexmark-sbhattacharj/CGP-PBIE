FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash && apt-get install nodejs -yq

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update
RUN apt-get install yarn -yq

RUN mkdir /app
WORKDIR /app

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV SECRET_KEY_BASE=b2dd5e87d02e53dd299e9b1fb643d5af65af17ce58f1a5fafdc5af90d8ed49bc028773eccb2c63ec419b101e473149ec532506cfb297f2ce6bd4f072b9a36c6
EXPOSE 3000

COPY . /app
RUN rm Gemfile.lock
RUN gem update bundler
RUN bundle config set --local without 'development test'
RUN bundle install
RUN rm -fR coverage
RUN rm -fR .git
RUN rm -fR node_modules
RUN rm -fR fixtures
RUN rm -fR devops
RUN rm package-lock.json

RUN bundle exec rake assets:precompile
CMD ./bin/rails s puma -b 'ssl://0.0.0.0:3000?key=/app/.ssh/server.key&cert=/app/.ssh/server.crt'