FROM --platform=${BUILDPLATFORM} ruby:3.2.1-alpine
ENV RUBY_YJIT_ENABLE=1

LABEL maintainer="engineering@houseninja.co"
LABEL org.opencontainers.image.source="https://github.com/houseninjadojo/api"

# Add basic packages
RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  git \
  nodejs \
  tzdata \
  file \
  libsodium \
  aws-cli \
  imagemagick \
  vips

WORKDIR /app

# # Install standard Node modules
# COPY package.json yarn.lock /app/
# RUN yarn install --frozen-lockfile

# Install standard gems
COPY Gemfile* /app/
RUN bundle config set --local frozen 1 && \
  bundle install -j4 --retry 3

#### ONBUILD: Add triggers to the image, executed later while building a child image

# Install Ruby gems (for production only)
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config set --local without 'development test' && \
  bundle install -j4 --retry 3 && \
  # Precompile gems with Bootsnap (and ignore errors)
  bundle exec bootsnap precompile --gemfile || true && \
  # Remove unneeded gems
  bundle clean --force && \
  # Remove unneeded files from installed gems (cached *.gem, *.o, *.c)
  rm -rf /usr/local/bundle/cache/*.gem && \
  find /usr/local/bundle/gems/ -name "*.c" -delete && \
  find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy the whole application folder into the image
ONBUILD COPY . /app

# Precompile application code with Bootsnap (and ignore errors)
ONBUILD RUN bundle exec bootsnap precompile app/ lib/ || true

# # Compile assets with Webpacker or Sprockets
# #
# # Notes:
# #   1. Executing "assets:precompile" runs "yarn:install" prior
# #   2. Executing "assets:precompile" runs "webpacker:compile", too
# #   3. For an app using encrypted credentials, Rails raises a `MissingKeyError`
# #      if the master key is missing. Because on CI there is no master key,
# #      we hide the credentials while compiling assets (by renaming them before and after)
# #
# ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
# ONBUILD RUN mv config/credentials config/credentials.bak 2>/dev/null || true
# ONBUILD RUN --mount=type=secret,id=npmrc,dst=/root/.npmrc \
#   --mount=type=secret,id=yarnrc,dst=/root/.yarnrc.yml \
#   AWS_REGION=us-east-1 \
#   AWS_BUCKET_NAME=fake-bucket \
#   AWS_ACCESS_KEY_ID=fake-access-key-id \
#   AWS_SECRET_ACCESS_KEY=fake-secret-access-key \
#   RAILS_ENV=production \
#   # REDIS_URL="redis://redis:5432/0" \
#   SECRET_KEY_BASE=dummy \
#   RAILS_MASTER_KEY=dummy \
#   bundle exec rails assets:precompile
# ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true
# ONBUILD RUN mv config/credentials.bak config/credentials 2>/dev/null || true

# # Remove folders not needed in resulting image
# ONBUILD RUN rm -rf tmp/cache vendor/bundle test spec

# Remove folders not needed in resulting image
# This includes `app/javascript` which contains the JavaScript source code.
# Normally it is not needed in the resulting image, because it was compiled
# to `public/`. But if the app uses importmaps, the folder is still required
# for pinning and must not be removed.
ONBUILD RUN rm -rf node_modules yarn.lock .yarn vendor/bundle test spec app/packs
ONBUILD RUN if [ ! -f config/importmap.rb ]; then rm -rf app/javascript; fi

# Configure Entrypoint
ONBUILD RUN chmod +x entrypoint.sh
ONBUILD ENTRYPOINT ["entrypoint.sh"]
