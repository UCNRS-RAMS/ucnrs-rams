# Stage 1: Get Node and Yarn binaries
FROM node:22.21.1-slim AS node

# Stage 2: Build the Rails environment
FROM ruby:3.2.9

# Copy Node and Yarn from the 'node' stage into our Ruby stage
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/
COPY --from=node /usr/local/bin/yarn /usr/local/bin/

# Create symlinks so the system finds them
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/yarn/bin/yarn.js /usr/local/bin/yarn

# Install dependencies:
# ImageMagick for image processing, libmariadb-dev for the mysql2 gem
# cmake for rugged, a dependency of Pronto
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libmariadb-dev \
    imagemagick \
    cmake \
    git

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