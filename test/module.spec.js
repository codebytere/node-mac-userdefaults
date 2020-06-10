const { expect } = require('chai')
const { 
  getAllDefaults,
  getUserDefault,
  isKeyManaged,
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

    it('returns values for unknown user defaults', () => {
      const KEY = 'UserDefaultDoesNotExist';

      expect(getUserDefault('boolean', KEY)).to.equal(false);
      expect(getUserDefault('integer', KEY)).to.equal(0);
      expect(getUserDefault('float', KEY)).to.equal(0);
      expect(getUserDefault('double', KEY)).to.equal(0);
      expect(getUserDefault('string', KEY)).to.equal('');
      expect(getUserDefault('url', KEY)).to.equal('');
      expect(getUserDefault('array', KEY)).to.deep.equal([]);
      expect(getUserDefault('dictionary', KEY)).to.deep.equal({});
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

    it('should be able to set a user default to a string', () => {
      setUserDefault('string', 'StringTest', 'string-test')

      const stringDefault = getUserDefault('string', 'StringTest')
      expect(stringDefault).to.eq('string-test')
    })

    it('should be able to set a user default to a boolean', () => {
      setUserDefault('boolean', 'BooleanTest', true)

      const boolDefault = getUserDefault('boolean', 'BooleanTest')
      expect(boolDefault).to.be.true
    })

    it('should be able to set a user default to a double', () => {
      setUserDefault('double', 'DoubleTest', 1.0)

      const doubleDefault = getUserDefault('double', 'DoubleTest')
      expect(doubleDefault).to.equal(1.0)
    })

    it('should be able to set a user default to a float', () => {
      setUserDefault('float', 'FloatTest', 4.5)

      const floatDefault = getUserDefault('float', 'FloatTest')
      expect(floatDefault).to.equal(4.5)
    })

    it('should be able to set a user default to a url', () => {
      const url = 'https://codebyte.re'
      setUserDefault('url', 'URLTest', url)

      const urlDefault = getUserDefault('url', 'URLTest')
      expect(urlDefault).to.equal(url)
    })

    it('should be able to set a user default to an array', () => {
      const array = ['do', 're', 'mi']
      setUserDefault('array', 'ArrayTest', array)

      const arrayDefault = getUserDefault('array', 'ArrayTest')
      expect(arrayDefault).to.deep.equal(array)
    })

    it('should be able to set a user default to an object', () => {
      setUserDefault('dictionary', 'DictTest', { hello: 'world' })

      const dictDefault = getUserDefault('dictionary', 'DictTest')
      expect(dictDefault).to.deep.equal({ hello: 'world' })
    })
  })

  describe('isKeyManaged()', () => {
    it('returns a boolean', () => {
      const managed = isKeyManaged('AppleInterfaceStyle')
      expect(managed).to.be.a('boolean')
    })
  })
})
