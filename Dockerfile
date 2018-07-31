FROM ruby:2.3.4-alpine
RUN apk add --no-cache libc6-compat postgresql-libs xz-libs libxml2 libxslt nodejs tzdata
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG=.bundle/
ENV BUNDLE_BIN=bin
ENV BUNDLE_PATH=vendor/bundle
ENV BUNDLE_FROZEN=1
ENV PATH="/srv/app/bin:${PATH}"
WORKDIR /srv/app
COPY . /srv/app
ENTRYPOINT ["/srv/app/bin/bundle", "exec"]
CMD ["rails", "s"]
