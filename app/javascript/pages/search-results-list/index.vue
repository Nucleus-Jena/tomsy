<script>
import PageContent from '../page-content'
import AmbitionListItem from 'list-items/ambition-list-item'
import ProcessListItem from 'list-items/process-list-item'
import TaskListItem from 'list-items/task-list-item'
import DossierListItem from 'list-items/dossier-list-item'
import Requestable from 'mixins/requestable'
import Request from 'api/request'

export default {
  name: 'SearchResultsListPage',
  components: {
    PageContent,
    AmbitionListItem,
    ProcessListItem,
    TaskListItem,
    DossierListItem
  },
  mixins: [Requestable],
  props: {
    query: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      page: 1,
      result: null
    }
  },
  computed: {
    watched () { return [this.query, this.page].join() }
  },
  watch: {
    watched: {
      handler () {
        this.result = null
        this.fetchData()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({ method: Request.GET, url: this.$apiEndpoints.search.fulltext() },
        { query: this.query, page: this.page }, null, true)
    },
    onRequestSuccess: function (data) {
      this.result = data
    },
    listItemType (type) {
      switch (type) {
        case 'ambition': return AmbitionListItem
        case 'process': return ProcessListItem
        case 'task': return TaskListItem
        case 'dossier': return DossierListItem
        default: return null
      }
    },
    listItemLink (item) {
      switch (item.type) {
        case 'ambition': return { name: 'ambition', params: { ambitionId: item.object.id } }
        case 'process': return { name: 'process', params: { processId: item.object.id } }
        case 'task': return { name: 'task', params: { processId: item.object.process.id, taskId: item.object.id } }
        case 'dossier': return { name: 'dossier', params: { dossierId: item.object.id } }
        default: return null
      }
    }
  }
}
</script>
<template>
  <page-content
    class="page-search"
    :error="error"
    @reload="fetchData"
  >
    <div class="mt-4">
      <h1 class="text-h4 font-weight-light">
        Suche
      </h1>

      <div v-if="!requestableLoading && result">
        <div v-if="result.results.length === 0 || (result.searchedWithMisspellingsDueToLowResultCount && result.results.length > 0) || (result.suggestion)">
          <v-alert
            class="mt-6"
            border="top"
            colored-border
            type="info"
            elevation="2"
          >
            <p v-if="result.results.length === 0">
              Für Ihre Suche nach
              "{{ result.queryTerm }}"
              gibt es leider keine Ergebnisse.
            </p>
            <p v-if="result.searchedWithMisspellingsDueToLowResultCount && result.results.length > 0">
              Für Ihre Suche nach
              "{{ result.queryTerm }}"
              gab es nur wenige exakte Treffer. Es werden daher auch ähnliche Ergebnisse angezeigt.
            </p>
            <p v-if="result.suggestion">
              Meinten Sie:
              <router-link :to="{ name: 'search', params: { query: result.suggestion } }">
                {{ result.suggestion }}
              </router-link>
              ?
            </p>
          </v-alert>
        </div>
      </div>

      <v-list
        id="search-results"
        class="py-0"
      >
        <template v-if="!requestableLoading && result">
          <div
            v-for="(item, index) in result.results"
            :key="index"
          >
            <template v-if="listItemType(item.type)">
              <component
                :is="listItemType(item.type)"
                :value="item.object"
                :to="listItemLink(item)"
                ident
                :dense="false"
              >
                <template
                  v-if="item.highlights"
                  #snippets
                >
                  <div
                    v-for="(highlight, h_index) in item.highlights"
                    :key="h_index"
                    class="search-result-highlights"
                  >
                    <div class="overline font-weight-bold text--primary">
                      {{ highlight.key }}
                    </div>
                    <div
                      v-for="(value, f_index) in highlight.fragments"
                      :key="f_index"
                      v-html="value"
                    />
                  </div>
                </template>
              </component>
              <v-divider />
            </template>
          </div>
        </template>
        <v-list-item
          v-else
          class="py-2"
        >
          <v-list-item-content class="text-center">
            <v-progress-circular
              color="primary"
              indeterminate
            />
          </v-list-item-content>
        </v-list-item>
      </v-list>
      <div
        v-if="!requestableLoading && result && result.total_pages > 1"
        class="text-center ma-4"
      >
        <v-pagination
          v-model="page"
          circle
          :length="result.total_pages"
        />
      </div>
    </div>
  </page-content>
</template>
