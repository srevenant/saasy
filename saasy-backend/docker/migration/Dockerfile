FROM saasy-backend-base AS builder

ENV APP_NAME=reactor\
    BASEDIR=/app\
    MIX_ENV=prod

WORKDIR $BASEDIR/src

# build dependencies
RUN apk add --no-cache \
        gcc libc-dev libffi-dev linux-headers python3-dev make vim

# bring in only our dependency files first, then build dependencies
COPY src/apps/authx/mix.exs $BASEDIR/src/apps/authx/mix.exs
COPY src/apps/core/mix.exs $BASEDIR/src/apps/core/mix.exs
COPY src/apps/utils/mix.exs $BASEDIR/src/apps/utils/mix.exs
COPY src/apps/web/mix.exs $BASEDIR/src/apps/web/mix.exs
COPY src/mix.exs $BASEDIR/src/
COPY src/mix.lock $BASEDIR/src/

RUN mix deps.get && \
    mix deps.compile

# then bring in our source code -- this way we only compile what is required
COPY src/ $BASEDIR/src/

# this first line puts $BUILD_VERSION into mix.exs as version
COPY docker/release/set-version $BASEDIR/set-version
RUN /bin/bash $BASEDIR/set-version "$BUILD_VERSION"

WORKDIR $BASEDIR/src/

RUN mix deps.get && mix deps.compile
RUN mix compile

COPY docker/release/config.json $BASEDIR/src
COPY data $BASEDIR/../data
