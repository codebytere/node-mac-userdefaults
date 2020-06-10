const defaults = require('bindings')('defaults.node')

const VALID_TYPES = ['string', 'float', 'boolean', 'array', 'url', 'object', 'double']

function getUserDefault(key, type) {
  if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(' ,')}`)
  }

  return defaults.getUserDefault.call(this, key, type)
}

module.exports = {
  getUserDefault,
  getAllDefaults: defaults.getAllDefaults
}
