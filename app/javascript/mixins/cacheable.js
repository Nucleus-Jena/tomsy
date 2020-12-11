import cloneDeep from 'lodash/cloneDeep'
import isEqual from 'lodash/isEqual'

export default {
  props: {
    value: {}
  },
  data () {
    return {
      cacheValue: null
    }
  },
  methods: {
    createCacheValue: function () {
      this.cacheValue = cloneDeep(this.value)
    }
  },
  computed: {
    cachedValueChanged: function () {
      return !isEqual(this.value, this.cacheValue)
    }
  },
  watch: {
    value: {
      handler () {
        this.createCacheValue()
      },
      deep: true,
      immediate: true
    }
  }
}
