const { expect } = require('chai')
const { 
  getAllDefaults,
  getUserDefault
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
  describe('getAllDefaults()', () => {
    it('should return an object containing all current user defaults', () => {
      const allDefaults = getAllDefaults()
      expect(allDefaults).to.be.an.an('object')
      expect(Object.keys(allDefaults).length).to.be.gte(1)
    })
  })

  describe('getUserDefault()', () => {
    it('should throw on invalid types', () => {
      expect(() => {
        getUserDefault('hello-world', 'bad-type')
      }).to.throw(`bad-type must be one of ${VALID_TYPES.join(' ,')}`)
    })
  })
})
