import join from 'lodash/join'

export default {
  mounted () {
    this.setPageTitle()
  },
  methods: {
    setPageTitle () {
      const titleParts = this.pageTitleParts
      if (titleParts && titleParts.length) {
        document.title = `${join(titleParts, ' • ')} • ${this.$t('general.appName')}`
      } else {
        document.title = this.$t('general.appName')
      }
    }
  }
}
