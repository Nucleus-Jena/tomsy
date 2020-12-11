<script>
import PageContent from 'pages/page-content'
import ProcessListItem from 'list-items/process-list-item'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import ProcessesCreateControl from '../../controls/processes-control/processes-create-control'
import debounce from 'lodash/debounce'
import PageTitle from 'mixins/page-title'

export default {
  name: 'ProcessesListPage',
  components: { PageContent, ProcessListItem, ProcessesCreateControl },
  mixins: [Requestable, PageTitle],
  data () {
    return {
      page: 1,
      total_pages: 1,
      order_options: [{ text: 'Erstellungsdatum – neueste zuerst', value: 'desc' }, { text: 'Erstellungsdatum – älteste zuerst', value: 'asc' }],
      order: 'desc',
      tab_categories: [],
      selectedTab: 'RUNNING',
      queryText: null,
      search: null,
      selectedAssignees: [],
      selectedContributors: [],
      selectedProcessDefinitions: [],
      users: [],
      process_definitions: [],
      selectedAmbitions: [],
      ambitions: [],
      processes: [],
      processCreateControlOpen: false
    }
  },
  computed: {
    pageTitleParts () {
      return ['Maßnahmen']
    },
    multiselectForms () {
      return [this.selectedTab, this.selectedAssignees, this.selectedContributors, this.selectedProcessDefinitions, this.selectedAmbitions, this.page, this.order].join()
    }
  },
  watch: {
    queryText: debounce(function () {
      this.fetchData()
    }, 500),
    multiselectForms () {
      this.fetchData()
    }
  },
  created () {
    this.fetchData()
  },
  methods: {
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({ method: Request.GET, url: this.$apiEndpoints.processes.index() },
        {
          query: this.queryText,
          page: this.page,
          order: this.order,
          tab_category: this.selectedTab,
          assignee_ids: this.selectedAssignees,
          contributor_ids: this.selectedContributors,
          process_definition_ids: this.selectedProcessDefinitions,
          ambition_ids: this.selectedAmbitions
        }, null, true)
    },
    onRequestSuccess: function (data) {
      this.total_pages = data.total_pages
      this.processes = data.result
      this.tab_categories = data.tab_categories
      this.users = data.users
      this.process_definitions = data.process_definitions
      this.ambitions = data.ambitions
    }
  }
}
</script>
<template>
  <page-content
    class="page-processes-list"
    :error="error"
    @reload="fetchData"
  >
    <div
      ref="container"
      class="d-flex justify-space-between mt-4"
      style="position: relative"
    >
      <h1 class="text-h4 font-weight-light pt-1">
        Maßnahmen
      </h1>

      <processes-create-control
        :attach="$refs.container"
        absolute
        :nudge-bottom="60"
        close-on-click
        @opened="processCreateControlOpen = true"
        @closed="processCreateControlOpen = false"
      >
        <template #activator="{ on }">
          <v-btn
            color="primary"
            text
            :disabled="processCreateControlOpen"
            v-on="on"
          >
            Maßnahme starten
          </v-btn>
        </template>
      </processes-create-control>
    </div>

    <v-card
      class="mt-4"
      elevation="0"
      outlined
    >
      <v-tabs
        v-model="selectedTab"
        class="d-flex"
      >
        <v-tab
          v-for="tab in tab_categories"
          :key="tab.value"
          :href="'#'+tab.value"
          @click="page = 1"
        >
          {{ tab.text }}
          <v-badge
            class="ml-1"
            color="grey lighten-1"
            :content="tab.count || '0'"
            dense
            inline
          />
          <!-- TODO: vue turns 0 into false and renders nothing - better solution?-->
        </v-tab>
      </v-tabs>

      <div class="my-3 px-4">
        <v-row>
          <v-col class="pa-2">
            <v-text-field
              v-model="queryText"
              hide-details
              label="Maßnahmentitel"
              outlined
            />
          </v-col>

          <v-col
            class="pa-2"
            cols="4"
          >
            <v-select
              v-model="order"
              :items="order_options"
              hide-details
              label="Sortierung"
              outlined
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedAssignees"
              :items="users"
              label="Verantwortlicher"
              multiple
              outlined
            >
              <template v-slot:selection="data">
                <v-avatar
                  class="mr-2"
                  left
                  size="36"
                >
                  <v-img :src="data.item.avatar" />
                </v-avatar>
                {{ data.item.text }}
              </template>
              <template v-slot:item="data">
                <v-avatar
                  class="mr-2"
                  left
                  size="36"
                >
                  <v-img :src="data.item.avatar" />
                </v-avatar>
                {{ data.item.text }}
              </template>
            </v-autocomplete>
          </v-col>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedContributors"
              :items="users"
              label="Teilnehmer"
              multiple
              outlined
            >
              <template v-slot:selection="data">
                <v-avatar
                  class="mr-2"
                  left
                  size="36"
                >
                  <v-img :src="data.item.avatar" />
                </v-avatar>
                {{ data.item.text }}
              </template>
              <template v-slot:item="data">
                <v-avatar
                  class="mr-2"
                  left
                  size="36"
                >
                  <v-img :src="data.item.avatar" />
                </v-avatar>
                {{ data.item.text }}
              </template>
            </v-autocomplete>
          </v-col>
        </v-row>
        <v-row>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedAmbitions"
              :items="ambitions"
              label="Ziel"
              multiple
              outlined
            />
          </v-col>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedProcessDefinitions"
              :items="process_definitions"
              label="Art der Maßnahme"
              multiple
              outlined
            />
          </v-col>
        </v-row>
      </div>
    </v-card>
    <v-list class="py-0">
      <template v-if="!requestableLoading">
        <div
          v-for="process in processes"
          :key="process.id"
        >
          <process-list-item
            :value="process"
            :to="{name: 'process', params: { processId: process.id }}"
            indent
            :dense="false"
          />
          <v-divider />
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
      v-if="!requestableLoading && processes && total_pages > 1"
      class="text-center ma-4"
    >
      <v-pagination
        v-model="page"
        circle
        :length="total_pages"
      />
    </div>
    <div v-if="!requestableLoading && processes && processes.length === 0">
      <v-alert
        class="mt-6"
        border="top"
        colored-border
        type="info"
        elevation="2"
      >
        Für diese Filtereinstellungen gibt es leider keine Ergebnisse.
      </v-alert>
    </div>
  </page-content>
</template>
