import axios from 'axios'
import merge from 'lodash/merge'
import ApiError from './error/api-error'
import RequestError from './error/request-error'
import ResponseError from './error/response-error'
import ValidationError from './error/validation-error'

const csrfToken = document.querySelector('[name="csrf-token"]') || { content: 'no-csrf-token' }
const axiosInstance = axios.create({
  headers: {
    common: {
      'X-CSRF-Token': csrfToken.content,
      Accept: 'application/json'
    }
  }
})

export default class Request {
  constructor () {
    this.loading = false
    this.error = null
    this.cancelTokenSource = null
  }

  static get GET () {
    return 'get'
  }

  static get POST () {
    return 'post'
  }

  static get PATCH () {
    return 'patch'
  }

  static get PUT () {
    return 'put'
  }

  static get DELETE () {
    return 'delete'
  }

  static get METHODS () {
    return [Request.GET, Request.POST, Request.PATCH, Request.PUT, Request.DELETE]
  }

  cancel () {
    if (this.cancelTokenSource) {
      this.cancelTokenSource.cancel()
    }
  }

  reset () {
    this.error = null
  }

  request (method, url, params = null, payload = null, useCancelToken) {
    return new Promise((resolve, reject) => {
      if (useCancelToken) {
        this.cancel()
        this.cancelTokenSource = axios.CancelToken.source()
      }

      this.loading = true

      const config = merge({
        url: url,
        method: method
      }, this.cancelTokenSource ? { cancelToken: this.cancelTokenSource.token } : {},
      params ? { params: params } : {},
      payload ? { data: payload } : {}
      )

      axiosInstance.request(config)
        .then(response => {
          this.error = null
          resolve(response.data)
        })
        .catch(error => {
          if (!axios.isCancel(error)) {
            if (error.response) {
              if (error.response.status === 422) {
                this.error = new ValidationError(error)
              } else if (error.response.status === 401) {
                window.location.href = '/users/sign_in'
              } else {
                this.error = new ResponseError(error)
              }
            } else if (error.request) {
              this.error = new RequestError(error)
            } else {
              this.error = new ApiError(error.message)
            }
            reject(this.error)
          } else {
            this.error = null
          }
        })
        .then(() => {
          this.loading = false
        })
    })
  }

  get (url, params = null, useCancelToken = false) {
    return this.request(Request.GET, url, params, null, useCancelToken)
  }

  patch (url, params, payload) {
    return this.request(Request.PATCH, url, params, payload, false)
  }
}
