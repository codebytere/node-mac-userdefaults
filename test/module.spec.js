const { expect } = require('chai')
const { 
  getUserDefault,
} = require('../index')

const VALID_TYPES =  [
  'string',
  'float',
  'boolean',
  'array',
  'url',
  'object',
  'double'
]

describe('node-mac-userdefaults', () => {
  describe('getUserDefault()', () => {
    it('should throw on invalid types', () => {
      expect(() => {
        getUserDefault('hello-world', 'bad-type')
      }).to.throw(`bad-type must be one of ${VALID_TYPES.join(' ,')}`)
    })
  })
})
