ARG BASE_TAG=alpine
ARG BASE_IMG=library/ruby
ARG BUILDKIT_INLINE_CACHE=1

FROM ${BASE_IMG}:${BASE_TAG}

WORKDIR /home/app

RUN mkdir -p /usr/local/etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc \
  && echo 'gem: --no-document' > ~/.gemrc

RUN set -ex \
  && apk add --no-cache git tzdata build-base  docker docker-compose

ADD Gemfile Gemfile.lock *.gemspec /home/app/
ADD lib/prometheus/enumerated_store/version.rb /home/app/lib/prometheus/enumerated_store


RUN set -ex \
  && gem install bundler && gem update bundler \
  && bundle install --jobs=3 \
  && rm -rf /tmp/* /var/tmp/* /usr/src/ruby /root/.gem /usr/local/bundle/cache

ONBUILD ADD . /home/app/

ONBUILD RUN set -ex \
  && bundle install --jobs=3 \
  && rm -rf /tmp/* /var/tmp/* /usr/src/ruby /root/.gem /usr/local/bundle/cache

CMD ["tail", "-f", "/dev/null"]


