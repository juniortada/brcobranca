FROM ruby:2.7

RUN apt-get update -y \
      && apt-get upgrade -y \
      && apt-get install -y \
      ghostscript \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /tmp/* \
      && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock brcobranca.gemspec ./
COPY lib ./lib

# Install dependencies
RUN bundle install

# Copy the rest of the project files into the container
COPY . .

ENV RGhost_Config_GS_path=/usr/bin/gs

# Set the default command to start an interactive shell
CMD ["/bin/bash"]