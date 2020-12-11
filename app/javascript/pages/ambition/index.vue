<script>
import PageContent from '../page-content'
import SidebarLeft from '../sidebar-left'
import SidebarRight from '../sidebar-right'
import AmbitionDetails from './ambition-details'
import AmbitionSidebarRight from './ambition-sidebar-right'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import Ambition from 'mixins/models/ambition'
import PageTitle from 'mixins/page-title'

export default {
  name: 'AmbitionPage',
  components: {
    AmbitionSidebarRight,
    PageContent,
    SidebarLeft,
    SidebarRight,
    AmbitionDetails
  },
  mixins: [Requestable, PageTitle, Ambition],
  props: {
    ambitionId: {
      type: Number,
      required: true
    }
  },
  data () {
    return {
      ambition: null
    }
  },
  computed: {
    pageTitleParts () {
      return [...(this.ambition ? [this.ambition.referenceLabel] : []), 'Ziele']
    }
  },
  watch: {
    $props: {
      handler () {
        this.ambition = null
        this.fetchData()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({ method: Request.GET, url: this.$apiEndpoints.ambitions.get(this.ambitionId) },
        null, null, true)
    },
    onRequestSuccess: function (data) {
      this.ambition = data
      this.setPageTitle()
    }
  }
}
</script>
<template>
  <div class="page-ambition">
    <sidebar-left floating />

    <page-content
      :error="error"
      @reload="fetchData"
    >
      <ambition-details
        v-if="ambition "
        v-model="ambition"
      />
    </page-content>

    <sidebar-right>
      <ambition-sidebar-right
        v-if="ambition"
        v-model="ambition"
      />
    </sidebar-right>
  </div>
</template>
