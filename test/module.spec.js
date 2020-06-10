const { expect } = require('chai')
const { 
  getAllDefaults,
  getUserDefault,
  setUserDefault
} = require('../index')

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

describe('node-mac-userdefaults', () => {
  describe('getAllDefaults()', () => {
    it('should return an object containing all current user defaults', () => {
      const allDefaults = getAllDefaults()
      expect(allDefaults).to.be.an.an('object')
      expect(Object.keys(allDefaults).length).to.be.gte(1)
    })
  })

  describe('getUserDefault()', () => {
    it('should throw on extra arguments', () => {
      expect(() => {
        getUserDefault('bad-type', 'hello-world', 'blah')
      }).to.throw('Arguments must be (type, key)')
    })

    it('should throw on invalid types', () => {
      expect(() => {
        getUserDefault('bad-type', 'hello-world')
      }).to.throw(`bad-type must be one of ${VALID_TYPES.join(', ')}`)
    })
  })

  describe('setUserDefault()', () => {
    it('should throw on invalid types', () => {
      expect(() => {
        setUserDefault('bad-type', 'hello', 'world')
      }).to.throw(`bad-type must be one of ${VALID_TYPES.join(', ')}`)
    })

    it('should throw on mismatched values for types', () => {
      for (const type of VALID_TYPES) {
        expect(() => {
          setUserDefault(type, 'some-key', undefined)
        }).to.throw(`undefined must be a valid ${type}`)
      }
    })
  })
})
