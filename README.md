[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
 [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![Lint Status](https://github.com/codebytere/node-mac-userdefaults/workflows/Lint/badge.svg)](https://github.com/codebytere/node-mac-userdefaults/actions) [![Test Status](https://github.com/codebytere/node-mac-userdefaults/workflows/Test/badge.svg)](https://github.com/codebytere/node-mac-userdefaults/actions)

# node-mac-userdefaults

```js
$ npm i node-mac-userdefaults
```

This native Node.js module provides an interface to the user’s defaults database on macOS.

## API

### `defaults.getAllDefaults()`

Returns `Record<string, any>` - An object containing all currently set defaults and their values for the current user.

Example:
```js
const { getAllDefaults } = require('node-mac-userdefaults')

const allDefaults = getAllDefaults()

console.log(allDefaults)
/*
{
  'com.apple.springing.enabled': 1,
  'Brother MFC-J985DW': '1',
  'com.apple.trackpad.enableSecondaryClick': 1,
  'HP DeskJet 2600 series': '1',
  'com.apple.trackpad.rotateGesture': 1,
  NSNavPanelFileListModeForOpenMode2: 3,
  Country: 'US',
  'com.apple.preferences.timezone.selected_city': {
    AppleMapID: '\x1Dq\x13\x13u\x1C\x19'
  },
  'Brother MFC-L9570CDW series': '1',
  WebAutomaticSpellingCorrectionEnabled: 1,
  'com.apple.trackpad.momentumScroll': 1,
  AKLastIDMSEnvironment: 0,
  'Hewlett Packard MFP M477fdn': '1',
  NSAutomaticTextCompletionCollapsed: 0,
  'com.apple.trackpad.fourFingerPinchSwipeGesture': 2,
  AppleShowAllExtensions: 1,
  'com.apple.trackpad.threeFingerTapGesture': 0,
  NSQuitAlwaysKeepsWindows: 0,
  'com.apple.trackpad.fourFingerVertSwipeGesture': 2,
  NSLinguisticDataAssetsRequestTime: '2020-06-10 00:57:28 +0000',
  NSAutomaticPeriodSubstitutionEnabled: 1,
  'com.apple.springing.delay': 0,
  'HP ENVY 5000 series': '1',
  'com.apple.sound.beep.flash': 0,
  AppleShowScrollBars: 'Automatic',
  ...
*/
``` 

### `defaults.getUserDefault(type, key)`

* `key` String - The `NSUserDefault` to fetch, e.g `AppleInterfaceStyle`.
* `type` String - Can be one of `string`, `boolean`, `integer`, `float`, `double`,
  `url`, `array` or `dictionary`.

Returns `any` - The value of `key` in `NSUserDefaults` of type `type`.

Example:
```js
const { getUserDefault } = require('node-mac-userdefaults')

const interfaceStyle = getUserDefault('AppleInterfaceStyle', 'string')

console.log(interfaceStyle) // 'Dark'
``` 

### `defaults.setUserDefault(type, key, value)`

* `type` String - Can be `string`, `boolean`, `integer`, `float`, `double`, `url`, `array` or `dictionary`.
* `key` String - The `NSUserDefault` to update, e.g `AppleInterfaceStyle`.
* `value` any - The new value to set for `key`; must match type of `type`.

Sets the value of `key` in `NSUserDefaults`.

Example:
```js
const { setUserDefault } = require('node-mac-userdefaults')

setUserDefault('boolean', 'ApplePressAndHoldEnabled', true)
```

### `defaults.removeUserDefault(key)`

* `key` String - The `NSUserDefault` to remove, e.g `AppleInterfaceStyle`.

Removes the `key` in `NSUserDefaults`.

This can be used to restore the default or global value of a `key` previously set with `setUserDefault`.

Example:
```js
const { removeUserDefault } = require('node-mac-userdefaults')

removeUserDefault('ApplePressAndHoldEnabled')
```
