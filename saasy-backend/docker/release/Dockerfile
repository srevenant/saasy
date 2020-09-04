################################################################################
# stage1: builder - bring in all the ugly to build our app, result is a released package
FROM saasy-backend-base AS builder

ENV APP_NAME=reactor\
    BASEDIR=/app\
    MIX_ENV=prod

WORKDIR $BASEDIR/src

# build dependencies
RUN apk add --no-cache \
        gcc libc-dev libffi-dev linux-headers python3-dev make

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
ARG BUILD_VERSION
COPY docker/release/set-version $BASEDIR/set-version
RUN /bin/bash $BASEDIR/set-version "$BUILD_VERSION"
RUN mix phx.digest
RUN mix distillery.release

RUN mkdir -p $BASEDIR/$APP_NAME && \
    echo tar -xzf _build/$MIX_ENV/rel/$APP_NAME/releases/$BUILD_VERSION/$APP_NAME.tar.gz -C $BASEDIR/$APP_NAME && \
    tar -xzf _build/$MIX_ENV/rel/$APP_NAME/releases/$BUILD_VERSION/$APP_NAME.tar.gz -C $BASEDIR/$APP_NAME

################################################################################
# stage2: released
FROM saasy-backend-base

ARG BUILD_VERSION
ENV APP_NAME=reactor\
    BASEDIR=/app\
    MIX_ENV=prod

WORKDIR $BASEDIR/$APP_NAME

COPY --from=builder $BASEDIR/$APP_NAME .
# Usually reflex brings this in
#CMD launch app

COPY docker/release/config.json /app/reactor
COPY docker/release/help.txt /app/reactor
CMD /app/reactor/bin/reactor foreground
