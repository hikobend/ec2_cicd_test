FROM ruby:2.7

# Install dependencies
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y nodejs yarn nginx \
    && mkdir /myapp

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set working directory
WORKDIR /myapp

# Install Gems
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Copy the application code
COPY . /myapp

# Copy entrypoint script and set permissions
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Expose ports and start Nginx and Rails server
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
