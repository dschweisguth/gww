// This project uses ESLint 8 and the old config file format to match Code Climate
module.exports = {
  extends: 'eslint:recommended',
  env: {
    es2024: true,
    browser: true,
    jquery: true
  },
  globals: {
    google: true,
    GWW: true
  },
  rules: {
    'array-callback-return': 'warn',
    'no-constant-binary-expression': 'warn',
    'no-constructor-return': 'warn',
    'no-new-native-nonconstructor': 'warn',
    'no-self-compare': 'warn',
    'no-template-curly-in-string': 'warn',
    'no-unmodified-loop-condition': 'warn',
    'no-unreachable-loop': 'warn',
    'consistent-return': 'warn',
    'curly': 'warn',
    'eqeqeq': 'warn',
    'no-lone-blocks': 'warn',
    'no-loop-func': 'warn',
    'no-multi-assign': 'warn',
    'no-return-assign': 'warn',
    'no-unused-expressions': 'warn',
    'no-useless-call': 'warn',
    'no-useless-concat': 'warn',
    'no-useless-constructor': 'warn',
    'no-useless-rename': 'warn',
    'no-useless-return': 'warn',
    'strict': 'warn',
  }
};
