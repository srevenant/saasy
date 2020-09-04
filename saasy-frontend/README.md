# SaaSy Frontend

_Copyright 2019 Protos, LLC_

This is a React standalone app, to be used with perform-backend via GraphQL.

## Conventions

Common React conventions, plus:

* `src/components` - global components used across screents
* `src/screens` - a discrete screen used in the application
* `src/screens/component` - use as little as possible – this is for breaking out discrete components used only by that screen
* `src/utils` - utility/lib code not a jsx
* `src/components` - global data definitions
* functional programming is the goal.
* small, focused files.  Keep new files under 100-150 lines where possible.
* standard.js - goal is everything formats in this spec
* TDD is ideal - let's focus on that style of development - everything has tests

## Notes on events

Flux, Redux, or other event models: although I have explored several, right now
I'm keeping it fairly hand wired.  We can always mix it up in the future.

For now, I'm using a simle event emitter, which is contained within specific component
types.

## Developing

    yarn install
    yarn start

The last command will open the app in development mode, and your browser should
be directed to [http://localhost:3000](http://localhost:3000).

The page will reload if you make edits.<br>
You will also see any lint errors in the console.

## Testing

    yarn test

Lots of work to be done here, still wip.

([running tests](https://facebook.github.io/create-react-app/docs/running-tests))
