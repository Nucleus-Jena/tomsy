<script>
import Vue from 'vue'
import PageContent from '../page-content'
import AmbitionListItem from 'list-items/ambition-list-item'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import MenuCardControl from 'controls/menu-card-control'
import MenuCardActionContent from 'controls/menu-card-control/menu-card-action-content'
import debounce from 'lodash/debounce'
import PageTitle from 'mixins/page-title'

export default {
  name: 'AmbitionsListPage',
  components: { PageContent, AmbitionListItem, MenuCardControl, MenuCardActionContent },
  mixins: [Requestable, PageTitle],
  data () {
    return {
      page: 1,
      total_pages: 1,
      order_options: [{ text: 'Erstellungsdatum – neueste zuerst', value: 'desc' }, { text: 'Erstellungsdatum – älteste zuerst', value: 'asc' }],
      order: 'desc',
      tab_categories: [],
      selectedTab: 'OPEN',
      queryText: null,
      search: null,
      ambitions: [],
      selectedAssignees: [],
      selectedContributors: [],
      selectedProcessDefinitions: [],
      users: [],
      process_definitions: [],
      newAmbitionTitle: '',
      ambitionCreateRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (ambition) => {
            this.$router.push({ name: 'ambition', params: { ambitionId: ambition.id } })
          }
        }
      })
    }
  },
  computed: {
    multiselectForms () {
      return [this.selectedTab, this.selectedAssignees, this.selectedContributors, this.selectedProcessDefinitions, this.page, this.order].join()
    },
    pageTitleParts () {
      return ['Ziele']
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
      this.request({ method: Request.GET, url: this.$apiEndpoints.ambitions.index() },
        {
          query: this.queryText,
          page: this.page,
          order: this.order,
          tab_category: this.selectedTab,
          assignee_ids: this.selectedAssignees,
          contributor_ids: this.selectedContributors,
          process_definition_ids: this.selectedProcessDefinitions
        }, null, true)
    },
    onRequestSuccess: function (data) {
      this.total_pages = data.total_pages
      this.ambitions = data.result
      this.tab_categories = data.tab_categories
      this.users = data.users
      this.process_definitions = data.process_definitions
    }
  }
}
</script>
<template>
  <page-content
    class="page-ambitions-list"
    :error="error"
    @reload="fetchData"
  >
    <div
      ref="container"
      class="d-flex justify-space-between mt-4"
      style="position: relative"
    >
      <h1 class="text-h4 font-weight-light pt-1">
        Ziele
      </h1>

      <menu-card-control
        :attach="$refs.container"
        absolute
        :nudge-bottom="60"
        close-on-click
        :loading="ambitionCreateRequestable.requestableLoading"
      >
        <template #activator="{ on }">
          <v-btn
            color="primary"
            text
            v-on="on"
          >
            Ziel erstellen
          </v-btn>
        </template>
        <template #content="{ instance }">
          <menu-card-action-content
            title="Neues Ziel erstellen"
            primary-btn-text="Erstellen"
            :primary-btn-disabled="newAmbitionTitle === ''"
            :loading="ambitionCreateRequestable.requestableLoading"
            :base-error-message="ambitionCreateRequestable.baseErrorMessage"
            @click-secondary-btn="instance.closeMenuCard"
            @click-primary-btn="ambitionCreateRequestable.request({method: 'post', url: $apiEndpoints.ambitions.create()}, null, {title: newAmbitionTitle})"
          >
            <template #default>
              <v-text-field
                v-model="newAmbitionTitle"
                label="Titel des neuen Ziels"
                :disabled="ambitionCreateRequestable.requestableLoading"
                error-count="5"
                :error-messages="ambitionCreateRequestable.validationErrorMessageFor('title')"
              />
            </template>
          </menu-card-action-content>
        </template>
      </menu-card-control>
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
              label="Zieltitel"
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
          v-for="ambition in ambitions"
          :key="ambition.id"
        >
          <ambition-list-item
            :value="ambition"
            :to="{name: 'ambition', params: { ambitionId: ambition.id }}"
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
      v-if="!requestableLoading && ambitions && total_pages > 1"
      class="text-center ma-4"
    >
      <v-pagination
        v-model="page"
        circle
        :length="total_pages"
      />
    </div>
    <div v-if="!requestableLoading && ambitions && ambitions.length === 0">
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
