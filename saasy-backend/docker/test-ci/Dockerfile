FROM saasy-backend-base

ARG MIX_ENV
ENV MIX_ENV test

RUN apk add --no-cache \
        gcc libc-dev libffi-dev linux-headers python3-dev make

WORKDIR /app/src

COPY src/ /app/src/

RUN mix do deps.get, deps.compile

ARG BUILD_ENV
COPY docker/$BUILD_ENV /docker/
