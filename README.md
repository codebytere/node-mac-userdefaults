[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
 [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![Lint Status](https://github.com/codebytere/node-mac-userdefaults/workflows/Lint/badge.svg)](https://github.com/codebytere/node-mac-userdefaults/actions)

# node-mac-userdefaults

```js
$ npm i node-mac-userdefaults
```

This native Node.js module provides an interface to the user’s defaults database on macOS.

## API

### `defaults.getUserDefault(key, type)`

* `key` String
* `type` String - Can be one of `string`, `boolean`, `integer`, `float`, `double`,
  `url`, `array` or `dictionary`.

Returns the value for a specified user default `key` of type `type`.

Example:
```js
const { getUserDefault } = require('node-mac-userdefaults')

const interfaceStyle = getUserDefault('AppleInterfaceStyle', 'string')

console.log(interfaceStyle) // dark
``` 
