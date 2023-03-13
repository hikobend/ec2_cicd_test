FROM ruby:3.1

# config.hostsにALBのホスト名を追加
RUN echo "config.hosts << 'micro-alb-484569792.ap-northeast-1.elb.amazonaws.com'" >> /app/config/environments/production.rb

ARG RUBYGEMS_VERSION=3.3.20
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem update --system ${RUBYGEMS_VERSION} && \
    bundle install
COPY . /app
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3001
CMD ["rails", "server", "-b", "0.0.0.0"]
