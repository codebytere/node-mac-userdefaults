const defaults = require('bindings')('defaults.node')

const VALID_TYPES = [
  'string',
  'float',
  'integer',
  'double',
  'boolean',
  'array',
  'url',
  'dictionary',
]

function getUserDefault(type, key) {
  if (arguments.length !== 2) {
    throw new Error('Arguments must be (type, key)')
  } else if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(', ')}`)
  }

  return defaults.getUserDefault.call(this, type, key)
}

function setUserDefault(type, key, value) {
  const isFloatOrDouble = (n) => !isNaN(parseFloat(n))
  const isObject = (o) => Object.prototype.toString.call(o) === '[object Object]'

  if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(', ')}`)
  }

  if (type === 'string' && typeof value !== 'string') {
    throw new Error(`${value} must be a valid string`)
  } else if (type === 'double' && !isFloatOrDouble(value)) {
    throw new Error(`${value} must be a valid double`)
  } else if (type === 'float' && !isFloatOrDouble(value)) {
    throw new Error(`${value} must be a valid float`)
  } else if (type === 'boolean' && typeof value !== 'boolean') {
    throw new Error(`${value} must be a valid boolean`)
  } else if (type === 'integer' && !Number.isInteger(value)) {
    throw new Error(`${value} must be a valid integer`)
  } else if (type === 'array' && !Array.isArray(value)) {
    throw new Error(`${value} must be a valid array`)
  } else if (type == 'dictionary' && !isObject(value)) {
    throw new Error(`${value} must be a valid dictionary`)
  } else if (type === 'url' && typeof value !== 'string') {
    throw new Error(`${value} must be a valid url`)
  }

  return defaults.setUserDefault.call(this, type, key, value)
}

module.exports = {
  getAllDefaults: defaults.getAllDefaults,
  getUserDefault,
  setUserDefault,
}
