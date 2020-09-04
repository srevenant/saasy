# Perform Backend

/Copyright 2019, Protos, LLC/

This is the backend for Perform.  It is elixir (optionally) wrapped in docker.

Details on using the app are defined in [src/README.md](src/README.md).

# Adding DB Elements
Quick reference

1. create a /db migration/ (Database DDL like): `apps/core/priv/repo/migrations/{date}_{name}`
2. create a /db schema model/ (mapping DDL to App) - use singular form of table: `apps/core/lib/core/model/{name}.ex, and {name}s.ex`
2. create a /db schema collection/ (less changeset more logical changes) - use plural form of table: `apps/core/lib/core/model/{name}s.ex`
3. add to /client context/ (helps make it visible): `apps/core/lib/core/context_client.ex`
4. create a [factory](https://github.com/thoughtbot/ex_machina) (as needed): `apps/core/test/support/factory.ex`
5. add to tests: `apps/core/test/{name}_test.exs` - may include both singular and plural schema tests

If using GraphQL also do:

1. add to graphql schema (if desired): `vibes/lib/vibes_web/schema/types.ex`
2. add graphql and other front-end tests

## Folder Structure

* Folder `src/` contains the elixir application.  See more at [src/README.md](src/README.md)
* Folder `docker/` contains the docker build bits, with support for multiple environments in each sub folder
* The launch script for dev is `docker/{env}/launch`
* The `./local` command is a useful wrapper for docker-compose.  It prints out what it is running, so you can adjust to suite your needs.  You can get a full syntax by just running the command `./local`
* Three environs are supported by `./local` which are shown by running the `./local` command.

## Developing

There are a few profiles for how the app can be run locally, and in release mode.  These are located in `docker/`.  Generally, you can use the `fullstack` profile (which fires up a database alongside your application).

### Elixir Configs

Recognize that Elixir has two ways of configuration: Compile time and Release/Runtime.  Although Compile time configurations include a `prod` profile, this is not where we store our production configurations--those instead come in at runtime after the release is made.

Know simply that compile time configurations are what you will see and use in the `src/config`, `src/apps/*/config` folders, and there are some hardwired settings which match the MIX_ENV:

* `:dev` - your local development
* `:test` - used during `mix test`
* `:prod` - the profile we compile against for a release

When we prepare for a release, we use Distillery, and it uses the `prod` environment variable.  The resulting image is then released into our own `dev`, `tst`, `prd` and `sbx` environments.  The configurations for these are brought in at runtime, using `config.json` which is created by reflex when the container is launched (you can see the code that enables this in the `src/rel/config.exs` as a provider).

Always include default values in your configuration (`{app}/config.exs`) even if they are empty arrays, this way in production it'll inherit properly.

### Running Locally

The `fullstack` docker profile can handle most of what your configuration needs are, and it uses an internal mysql database, so it does not collide with any other services.  It exposes this database on port 13306 (if you want to use a workbench to access it).

If you are doing a lot of development, you may want to reference the section: *Working without Docker*

Build your image (with internal data):

    ./local dev build

Run Phoenix (http://localhost:4010):

    ./local dev up

Run other mix tasks (such as *First Time DB* -- see below) from outside-into the container like:

    ./local dev run phx mix core.seeds

Or just get a shell inside the container, and run the bare mix tasks directly:

    ./local dev run-sh  /bin/bash
    # mix do ecto.reset, core.seeds, core.tenant add localhost admin@email

### First Time DB

When first run no db exists and it will error.  While it is running, run a `ecto.create` task (from an alternate terminal):

    mix ecto.setup

### Releases

The release process can be built locally with `./docker/release/build-local`, and you can run it with: `./docker/release/dev-up` -- note: local build will not work on building this container, because of the way the release containers are structured.

The local container version of a release application runs as such:

* There are three containers: one mariadb, one with the bare-bones release, and one in mix mode with source code imported into `/app/src` similar to the fullstack container.  Each are available for cross testing as needed.
* The profile exposes its port as 4001, so it can run concurrently with the `fullstack` version of the application.

### Testing

* Headers to set (if using postman):

    * X-Forwarded-Proto: https
    * Authorization: Bearer TOKEN -- get this from `mix authkey`

* Before you make a Pull Request, verify the basic `mix test` tests all pass, then verify the CI Testing container stack will pass `./docker/test-ci/run-tests`.
* If you are ready to merge your PR, you can do a final check using the release process: `./docker/release/dev-up` (you will need to initialize the DB).

### Working without Docker

You may want to work outside of docker, with a local database.  For MacOS you can do this by installing (requires homebrew):

    brew install elixir
    brew install mariadb
    mix local.hex --force
    mix local.rebar --force

Add an alias in your `/etc/hosts` for the database: `db`, and start/stop/use mariadb as needed with:

    mysql.server start
    mysql.server stop
    mysql -u root

Your mileage will vary with this setup.  You can cross-reference what is in the `fullstack` docker profile for more information on how to setup the app, if things are not working properly.

## Troubleshooting & Debugging

### Connecting a shell / iex (dev)

When developing, you can connect a shell to your running service with:

    ./local dev fullstack

And from there you can run iex:

    cd src; iex

### Connecting a shell / release

For a release container, you can get a shell into the container (kubectl ... exec /bin/sh), and run:

    ./bin/{appname} remote_console

    iex> Application.started_applications
