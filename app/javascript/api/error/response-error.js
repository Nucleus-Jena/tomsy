import ApiError from './api-error'

export default class ResponseError extends ApiError {
  constructor (error) {
    super(error.response.statusText)
    this.errorCode = error.response.status
  }
}
