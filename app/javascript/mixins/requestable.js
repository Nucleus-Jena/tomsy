import Request from 'api/request'
import isNil from 'lodash/isNil'
import isFunction from 'lodash/isFunction'
import isString from 'lodash/isString'
import isPlainObject from 'lodash/isPlainObject'
import has from 'lodash/has'
import defaults from 'lodash/defaults'

export function requestablePropFactory (propName = 'requestParameter') {
  return {
    props: {
      [propName]: {
        type: Object,
        default: undefined,
        validator: (prop) => {
          return isNil(prop) || (
            has(prop, 'method') && isString(prop.method) && Request.METHODS.indexOf(prop.method) !== -1 &&
              has(prop, 'url') && isString(prop.url)
          )
        }
      }
    }
  }
}

export default {
  data () {
    return {
      requestObject: new Request()
    }
  },
  methods: {
    hasRequestParameter (propName = 'requestParameter') {
      return !isNil(this[propName])
    },
    request (requestParameter, params = null, data = null, useCancelToken = false) {
      let payload = data

      if (!isNil(requestParameter.mapping)) {
        if (isFunction(requestParameter.mapping)) {
          payload = requestParameter.mapping(data)
        } else {
          payload = { [requestParameter.mapping]: data }
        }
      }

      if (!isNil(requestParameter.params) && isPlainObject(requestParameter.params)) {
        params = defaults(params, requestParameter.params)
      }

      this.requestObject.request(requestParameter.method, requestParameter.url, params, payload, useCancelToken)
        .then(data => {
          this.onRequestSuccess(data)
        })
        .catch(errors => {
          this.onRequestError(errors)
        })
    },
    cancelRequestable () {
      this.requestObject.cancel()
    },
    resetRequestable () {
      this.requestObject.reset()
    },
    onRequestError (errors) {
    },
    onRequestSuccess (data) {
    },
    validationErrorMessageFor (attribute) {
      return (this.requestObject.error) ? this.requestObject.error.forAttribute(attribute) : null
    }
  },
  computed: {
    requestableLoading () {
      return this.requestObject.loading
    },
    hasErrors () {
      return this.requestObject.error !== null
    },
    errorMessage () {
      return (this.requestObject.error) ? this.requestObject.error.forAll() : null
    },
    baseErrorMessage () {
      return (this.requestObject.error) ? this.requestObject.error.forOther() : null
    },
    error () {
      return this.requestObject.error
    }
  }
}
