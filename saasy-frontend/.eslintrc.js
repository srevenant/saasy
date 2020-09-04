module.exports = {
  extends: [
    // 'plugin:lodash/recommended',
    'plugin:flowtype/recommended',
    'plugin:react/recommended',
    'prettier',
    'prettier/react'
  ],
  settings: {
    react: {
      version: 'detect'
    }
  },
  parser: 'babel-eslint',
  plugins: ['flowtype', 'react', 'import', 'lodash', 'prettier'],
  env: { browser: true },
  rules: {
    'import/export': 2,
    'import/no-deprecated': 1,
    'no-unused-vars': 1,
    'react/prefer-stateless-function': [2, { ignorePureComponents: true }],
    'react/require-default-props': 0
    /*
    'react/forbid-prop-types': 1,
    'no-underscore-dangle': 0,
    'import/no-named-as-default': 1,
    'import/no-amd': [2, 'allow-primitive-modules'],
    'import/no-commonjs': [2, 'allow-primitive-modules'],
    'import/no-unresolved': 2,
    'class-methods-use-this': 0,
    'max-len': 0,
    'lodash/prefer-lodash-method': [2, { ignoreObjects: ['React\\.Children'] }],
    'import/no-extraneous-dependencies': 0, // conflicts with our method of using package.json files for resolvers
    'import/imports-first': 0, // turning this off for now, can sort the imports later
    'no-console': 0,
    'react/jsx-filename-extension': [1, { extensions: ['.js', '.jsx'] }],

    // 'react/require-extension' rule used eslint-config-airbnb/rules/react.js has been deprecated
    // in favor of 'import/extensions'. (ESLint will still give a warning until eslint-config-airbnb
    // removes the deprecated rule.)
    'import/extensions': [2, { js: 'never', jsx: 'never' }],
    'prettier/prettier': [
      'error',
      {
        trailingComma: 'all',
        singleQuote: true,
        printWidth: 120,
        bracketSpacing: true,
      },
    ]
      */
  },
  globals: {
    fetch: false,
    _: false,
    sinon: false
  },
  settings: {
    'import/resolver': 'webpack',
    flowtype: { onlyFilesWithFlowAnnotation: true }
  }
}
