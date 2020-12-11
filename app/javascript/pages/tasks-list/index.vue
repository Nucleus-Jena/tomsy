<script>
import PageContent from '../page-content'
import TaskListItem from 'list-items/task-list-item'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import PageTitle from 'mixins/page-title'
import map from 'lodash/map'
import parseInt from 'lodash/parseInt'

export default {
  name: 'TasksListPage',
  components: { PageContent, TaskListItem },
  mixins: [Requestable, PageTitle],
  props: {
    query: {
      type: Object,
      default: function () { return {} }
    }
  },
  data () {
    return {
      page: 1,
      total_pages: 1,
      order_options: [{ text: 'Erstellungsdatum – neueste zuerst', value: 'desc' }, { text: 'Erstellungsdatum – älteste zuerst', value: 'asc' }],
      order: 'desc',
      tab_categories: [],
      selectedTab: 'STARTED',
      users: [],
      selectedAssignees: [],
      selectedContributors: [],
      process_definitions: [],
      selectedProcessDefinitions: [],
      ambitions: [],
      selectedAmbitions: [],
      task_definitions: [],
      selectedTaskDefinitions: [],
      tasks: []
    }
  },
  computed: {
    pageTitleParts () {
      return ['Aufgaben']
    }
  },
  watch: {
    query: {
      handler () {
        this.initializeFilter()
        this.fetchData()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    initializeFilter () {
      this.page = 1
      this.order = 'desc'
      this.selectedTab = 'STARTED'
      this.selectedAssignees = []
      this.selectedContributors = []
      this.selectedProcessDefinitions = []
      this.selectedTaskDefinitions = []
      this.selectedAmbitions = []

      if (this.query) {
        if (this.query.tab) this.selectedTab = this.query.tab
        if (this.query.assignees) this.selectedAssignees = map([this.query.assignees].flat(), parseInt)
        if (this.query.contributors) this.selectedContributors = map([this.query.contributors].flat(), parseInt)
        if (this.query.process_definitions) this.selectedProcessDefinitions = map([this.query.process_definitions].flat(), parseInt)
        if (this.query.task_definitions) this.selectedTaskDefinitions = map([this.query.task_definitions].flat(), parseInt)
        if (this.query.ambitions) this.selectedAmbitions = map([this.query.ambitions].flat(), parseInt)
        if (this.query.order) this.order = this.query.order
        if (this.query.page) this.page = parseInt(this.query.page)
      }
    },
    applyFilter (resetPage) {
      if (resetPage) this.page = 1

      this.$router.replace({
        query: {
          tab: this.selectedTab,
          assignees: this.selectedAssignees,
          contributors: this.selectedContributors,
          process_definitions: this.selectedProcessDefinitions,
          task_definitions: this.selectedTaskDefinitions,
          ambitions: this.selectedAmbitions,
          order: this.order,
          page: this.page
        }
      })
    },
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({ method: Request.GET, url: this.$apiEndpoints.tasks.index() },
        {
          page: this.page,
          order: this.order,
          tab_category: this.selectedTab,
          assignee_ids: this.selectedAssignees,
          contributor_ids: this.selectedContributors,
          process_definition_ids: this.selectedProcessDefinitions,
          task_definition_ids: this.selectedTaskDefinitions,
          ambition_ids: this.selectedAmbitions
        }, null, true)
    },
    onRequestSuccess: function (data) {
      this.total_pages = data.total_pages
      this.tasks = data.result
      this.tab_categories = data.tab_categories
      this.users = data.users
      this.process_definitions = data.process_definitions
      this.ambitions = data.ambitions
      this.task_definitions = data.task_definitions
    }
  }
}
</script>
<template>
  <page-content
    class="page-tasks-list"
    :error="error"
    @reload="fetchData"
  >
    <div class="d-flex justify-space-between mt-4">
      <h1 class="text-h4 font-weight-light pt-1">
        Aufgaben
      </h1>
    </div>

    <v-card
      class="mt-4"
      elevation="0"
      outlined
    >
      <v-tabs
        v-model="selectedTab"
        class="d-flex"
        @change="applyFilter(true)"
      >
        <v-tab
          v-for="tab in tab_categories"
          :key="tab.value"
          :href="'#' + tab.value"
        >
          {{ tab.text }}
          <v-badge
            class="ml-1"
            color="grey lighten-1"
            :content="String(tab.count)"
            dense
            inline
          />
        </v-tab>
      </v-tabs>

      <div class="my-3 px-4">
        <v-row>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedAssignees"
              :items="users"
              label="Verantwortlicher"
              multiple
              outlined
              @change="applyFilter(true)"
            >
              <template v-slot:selection="data">
                <v-avatar
                  v-if="data.item.avatar"
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
                  v-if="data.item.avatar"
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
              @change="applyFilter(true)"
            >
              <template v-slot:selection="data">
                <v-avatar
                  v-if="data.item.avatar"
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
                  v-if="data.item.avatar"
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
            <v-select
              v-model="order"
              :items="order_options"
              hide-details
              label="Sortierung"
              outlined
              @change="applyFilter(false)"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedTaskDefinitions"
              :items="task_definitions"
              label="Art der Aufgabe"
              multiple
              outlined
              @change="applyFilter(true)"
            />
          </v-col>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedProcessDefinitions"
              :items="process_definitions"
              label="Art der Maßnahme"
              multiple
              outlined
              @change="applyFilter(true)"
            />
          </v-col>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedAmbitions"
              :items="ambitions"
              label="Ziel"
              multiple
              outlined
              @change="applyFilter(true)"
            />
          </v-col>
        </v-row>
      </div>
    </v-card>

    <v-list class="py-0">
      <template v-if="!requestableLoading">
        <div
          v-for="task in tasks"
          :key="task.id"
        >
          <task-list-item
            :value="task"
            :to="{name: 'task', params: { processId: task.process.id, taskId: task.id }}"
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
      v-if="!requestableLoading && tasks && total_pages > 1"
      class="text-center ma-4"
    >
      <v-pagination
        v-model="page"
        circle
        :length="total_pages"
        @input="applyFilter(false)"
      />
    </div>
    <div v-if="!requestableLoading && tasks && tasks.length === 0">
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
