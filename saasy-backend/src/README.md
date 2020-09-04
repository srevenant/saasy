# Perform Backend

Time & Performance management

## Getting started

NOTE: I switched to use Postgres, so it still needs to be re-integrated w/Docker.

Decide if you are doing docker or local and build appropriately [see higher level
readme](../README.md).

After starting the app, you will need to setup the db. This uses `mix` commands,
which you can get in docker `./local dev sh` or directly from the `src/` shell
if not running in docker:

    mix ecto.setup
    mix core.seeds
    mix core.tenant add localhost yourname@domain.com

The latter uses whichever email you are signing in from Google with.  This will
create your user as the admin.

Afterwards, you should run the app in one of two ways:

    `./local dev up`
    `mix phx.server`

In both cases, the application is accessible at http://localhost:4010

## note

mix test.watch  mix_test_watch
