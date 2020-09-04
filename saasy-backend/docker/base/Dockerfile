################################################################################
# base container elixir+alpine+python3+reflex
FROM elixir:1.8-alpine

RUN apk add --no-cache \
        bash libffi python3 &&\
    apk add --no-cache --virtual .build-deps \
        gcc g++ libc-dev libffi-dev linux-headers python3-dev make &&\
    pip3 install --upgrade pip &&\
    pip3 install rfxcmd &&\
    apk del .build-deps && rm -rf ~/.cache &&\
    mix local.hex --force && \
    mix local.rebar --force && \
    #mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez
    mix archive.install --force hex phx_new 1.4.0
