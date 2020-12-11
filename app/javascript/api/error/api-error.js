export default class ApiError {
  constructor (message) {
    this.errorCode = null
    this.errorMessage = message
  }

  forAttribute (attribute) {
    return null
  }

  forOther () {
    return this.errorMessage
  }

  forAll () {
    return this.forOther()
  }

  code () {
    return this.errorCode
  }
}
