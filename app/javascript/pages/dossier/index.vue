<script>
import PageContent from '../page-content'
import DossierDetails from './dossier-details'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import PageTitle from 'mixins/page-title'

export default {
  name: 'DossierPage',
  components: {
    PageContent,
    DossierDetails
  },
  mixins: [Requestable, PageTitle],
  props: {
    dossierId: {
      type: Number,
      required: true
    }
  },
  data () {
    return {
      dossier: null
    }
  },
  computed: {
    pageTitleParts () {
      return [...(this.dossier ? [this.dossier.title] : []), 'Dossiers']
    }
  },
  watch: {
    $props: {
      handler () {
        this.dossier = null
        this.fetchData()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({ method: Request.GET, url: this.$apiEndpoints.dossiers.get(this.dossierId) },
        null, null, true)
    },
    onRequestSuccess: function (data) {
      this.dossier = data
      this.setPageTitle()
    }
  }
}
</script>
<template>
  <div class="page-dossier">
    <page-content
      :error="error"
      @reload="fetchData"
    >
      <dossier-details
        v-if="dossier "
        v-model="dossier"
      />
    </page-content>
  </div>
</template>
