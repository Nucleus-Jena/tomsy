import ApiError from './api-error'
import join from 'lodash/join'
import map from 'lodash/map'

export default class ValidationError extends ApiError {
  constructor (error) {
    super()
    this.errors = error.response.data
    this.errorCode = error.response.status
  }

  forAttribute (attribute) {
    return join(this.errors[attribute], ', ')
  }

  forOther () {
    return null
  }

  forAll () {
    return join(map(this.errors, (value, key) => { return this.forAttribute(key) }), ', ')
  }
}
