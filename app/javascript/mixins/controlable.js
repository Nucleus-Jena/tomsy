import isNil from 'lodash/isNil'

export default {
  props: {
    label: {
      type: String,
      default: ''
    },
    loading: Boolean,
    disabled: Boolean,
    errorMessages: {
      type: [String, Array],
      default: () => []
    },
    hint: {
      type: String,
      default: undefined
    },
    persistentHint: Boolean
  },
  computed: {
    controlLoading () {
      return this.hasRequestParameter() ? this.requestableLoading : this.loading
    },
    controlDisabled () {
      return this.disabled || this.controlLoading
    },
    controlErrorMessages () {
      return this.hasRequestParameter() ? this.errorMessage : this.errorMessages
    },
    controlHasErrors () {
      return this.hasRequestParameter() ? this.hasErrors : (!isNil(this.errorMessages) && (this.errorMessages.length > 0))
    }
  },
  methods: {
    controlOnChange () {
      if (this.cachedValueChanged) {
        if (this.hasRequestParameter()) {
          this.request(this.requestParameter, null, this.cacheValue)
        } else {
          this.$emit('input', this.cacheValue)
        }
      }
    }
  }
}
