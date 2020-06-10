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

function getAllDefaults(domain) {
  if (domain && typeof domain !== 'string') {
    throw new TypeError('domain must be a valid string')
  }

  return defaults.getAllDefaults.call(this, domain)
}

function getUserDefault(type, key, domain) {
  if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(', ')}`)
  } else if (domain && typeof domain !== 'string') {
    throw new TypeError('domain must be a valid string')
  }

  return defaults.getUserDefault.call(this, type, key, domain)
}

function setUserDefault(type, key, value, domain) {
  if (!VALID_TYPES.includes(type)) {
    throw new TypeError(`${type} must be one of ${VALID_TYPES.join(', ')}`)
  } else if (domain && typeof domain !== 'string') {
    throw new TypeError('domain must be a valid string')
  }

  const isFloatOrDouble = (n) => !isNaN(parseFloat(n))
  const isObject = (o) => Object.prototype.toString.call(o) === '[object Object]'

  if (type === 'string' && typeof value !== 'string') {
    throw new TypeError('value must be a valid string')
  } else if (type === 'double' && !isFloatOrDouble(value)) {
    throw new TypeError('value must be a valid double')
  } else if (type === 'float' && !isFloatOrDouble(value)) {
    throw new TypeError('value must be a valid float')
  } else if (type === 'boolean' && typeof value !== 'boolean') {
    throw new TypeError('value must be a valid boolean')
  } else if (type === 'integer' && !Number.isInteger(value)) {
    throw new TypeError('value must be a valid integer')
  } else if (type === 'array' && !Array.isArray(value)) {
    throw new TypeError('value must be a valid array')
  } else if (type == 'dictionary' && !isObject(value)) {
    throw new TypeError('value must be a valid dictionary')
  } else if (type === 'url' && typeof value !== 'string') {
    throw new TypeError('value must be a valid url')
  }

  return defaults.setUserDefault.call(this, type, key, value, domain)
}

function isKeyManaged(key, domain) {
  if (domain && typeof domain !== 'string') {
    throw new TypeError('domain must be a valid string')
  }

  return defaults.isKeyManaged.call(this, key, domain)
}

function removeUserDefault(key, domain) {
  if (domain && typeof domain !== 'string') {
    throw new TypeError('domain must be a valid string')
  }

  return defaults.removeUserDefault.call(this, key, domain)
}

function addDomain(name) {
  if (typeof name !== 'string') {
    throw new TypeError('domain name must be a valid string')
  }

  return defaults.addDomain.call(this, name)
}

function removeDomain(name) {
  if (typeof name !== 'string') {
    throw new TypeError('domain name must be a valid string')
  }

  return defaults.removeDomain.call(this, name)
}

module.exports = {
  addDomain,
  getAllDefaults,
  getUserDefault,
  isKeyManaged,
  setUserDefault,
  removeDomain,
  removeUserDefault,
}
