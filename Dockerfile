# Stage 1: Get Node and Yarn binaries
FROM node:22.21.1-slim AS node

# Stage 2: Build the Rails environment
FROM ruby:3.2.9

# Copy Node.js and package managers from the 'node' stage
COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/share/man /usr/local/share/man

# Remove existing yarn/npm symlinks and enable corepack
RUN rm -f /usr/local/bin/yarn /usr/local/bin/yarnpkg /usr/local/bin/npm /usr/local/bin/npx && \
    corepack enable && corepack prepare yarn@stable --activate


# Install dependencies:
# ImageMagick for image processing, libmariadb-dev for the mysql2 gem
# cmake for rugged, a dependency of Pronto
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libmariadb-dev \
    imagemagick \
    cmake \
    git \
    chromium \
    chromium-driver

# Set the working directory inside the container
WORKDIR /app

# it may seem weird to copy but it makes code more portable later if not used for live
# development.

# The Dockerfile COPY handles the "heavy lifting"—installing gems and setting up
# the environment so the image can stand on its own.
# The Compose volumes creates the "bridge" so you can develop without having to rebuild
# the image every time you fix a typo.


# Copy the Gemfile and Gemfile.lock first to leverage Docker caching
COPY Gemfile ./
COPY Gemfile.lock ./
# Install gems
RUN bundle install

COPY package.json yarn.lock ./
# Install JS dependencies
RUN yarn install --check-files

# Copy the rest of the application code
COPY . .

# Expose the Rails port
EXPOSE 3000

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]