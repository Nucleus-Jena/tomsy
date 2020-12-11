import ApiError from './api-error'

export default class RequestError extends ApiError {
  constructor (_error) {
    super('Request Error!')
  }
}
