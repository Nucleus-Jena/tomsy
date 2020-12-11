<script>
import PageContent from '../page-content'
import UserDetails from './user-details'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import User from 'mixins/models/user'
import PageTitle from 'mixins/page-title'

export default {
  name: 'UserPage',
  components: {
    PageContent,
    UserDetails
  },
  mixins: [Requestable, PageTitle, User],
  props: {
    userId: {
      type: Number,
      required: true
    }
  },
  data () {
    return {
      user: null
    }
  },
  computed: {
    pageTitleParts () {
      return [...(this.user ? [this.user.referenceLabel] : []), 'Nutzer']
    }
  },
  watch: {
    $props: {
      handler () {
        this.user = null
        this.fetchData()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({ method: Request.GET, url: this.$apiEndpoints.users.show(this.userId) },
        null, null, true)
    },
    onRequestSuccess: function (data) {
      this.user = data
      this.setPageTitle()
    }
  }
}
</script>
<template>
  <page-content
    class="page-user"
    :error="error"
    @reload="fetchData"
  >
    <user-details
      v-if="user"
      :user="user"
    />
  </page-content>
</template>
