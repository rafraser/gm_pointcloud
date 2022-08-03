module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'airbnb-base',
  ],
  parserOptions: {
    sourceType: 'module',
  },
  rules: {
    'import/prefer-default-export': 'off',
    'no-console': 'off'
  },
};
