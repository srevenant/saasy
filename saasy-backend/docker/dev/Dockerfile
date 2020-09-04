FROM elixir:1.8-alpine

ARG MIX_ENV

WORKDIR /app/src

# DO NOT need in production (dev & debug tools):
#   inotify-tools git openssh postgresql-client bash
# python3 = internal health check
# inotify = development only
# nodejs = assets compile
RUN apk --no-cache update && \
    apk --no-cache add python3-dev libffi ca-certificates \
        inotify-tools git openssh bash vim \
        nodejs libffi-dev gcc libc-dev tar make && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.4.2

COPY src/mix.* /app/src/
COPY src/apps/core/mix.* /app/src/apps/core/
COPY src/apps/utils/mix.* /app/src/apps/utils/
COPY src/apps/web/mix.* /app/src/apps/web/

RUN mix deps.get && mix deps.compile
COPY src /app/src/

RUN mix compile

# these will be mounted in by docker-compose
CMD /docker/launch
