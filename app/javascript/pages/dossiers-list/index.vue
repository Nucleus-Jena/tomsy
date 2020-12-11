<script>
import PageContent from '../page-content'
import DossierListItem from 'list-items/dossier-list-item'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import DossierCreateControl from 'controls/dossiers/dossier-create-control'
import debounce from 'lodash/debounce'
import PageTitle from 'mixins/page-title'

export default {
  name: 'DossiersListPage',
  components: { PageContent, DossierListItem, DossierCreateControl },
  mixins: [Requestable, PageTitle],
  data () {
    return {
      page: 1,
      total_pages: 1,
      order_options: [{ text: 'Erstellungsdatum – neueste zuerst', value: 'desc' }, { text: 'Erstellungsdatum – älteste zuerst', value: 'asc' }],
      order: 'desc',
      queryText: null,
      dossiers: [],
      selectedDossierDefinitions: [],
      dossier_definitions: [],
      dossier_fields: [],
      selectedField: null,
      queryField: null,
      dossierCreateControlOpen: false
    }
  },
  computed: {
    multiselectForms () {
      return [this.selectedDossierDefinitions, this.page, this.order].join()
    },
    pageTitleParts () {
      return ['Dossiers']
    }
  },
  watch: {
    queryText: debounce(function () {
      this.fetchData()
    }, 500),
    queryField: debounce(function () {
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
      this.request({ method: Request.GET, url: this.$apiEndpoints.dossiers.index() },
        {
          query: this.queryText,
          page: this.page,
          order: this.order,
          definitions: this.selectedDossierDefinitions,
          field: this.selectedField,
          field_query: this.queryField
        }, null, true)
    },
    onRequestSuccess: function (data) {
      this.dossiers = data.result
      this.total_pages = data.total_pages
      this.dossier_definitions = data.dossier_definitions
      this.dossier_fields = data.dossier_fields
    }
  }
}
</script>
<template>
  <page-content
    class="page-dossiers-list"
    :error="error"
    @reload="fetchData"
  >
    <div
      ref="container"
      class="d-flex justify-space-between mt-4"
      style="position: relative"
    >
      <h1 class="text-h4 font-weight-light pt-1">
        Dossiers
      </h1>

      <dossier-create-control
        :attach="$refs.container"
        absolute
        :nudge-bottom="60"
        close-on-click
        @opened="dossierCreateControlOpen = true"
        @closed="dossierCreateControlOpen = false"
      >
        <template #activator="{ on }">
          <v-btn
            color="primary"
            text
            :disabled="dossierCreateControlOpen"
            v-on="on"
          >
            Dossier erstellen
          </v-btn>
        </template>
      </dossier-create-control>
    </div>

    <v-card
      class="mt-4"
      elevation="0"
      outlined
    >
      <div class="my-3 px-4">
        <v-row>
          <v-col class="pa-2">
            <v-text-field
              v-model="queryText"
              hide-details
              label="Dossiertitel"
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
              v-model="selectedDossierDefinitions"
              :items="dossier_definitions"
              label="Art des Dossiers"
              multiple
              outlined
              @change="selectedField = null; queryField = null"
            />
          </v-col>
          <v-col class="pa-2">
            <v-autocomplete
              v-model="selectedField"
              :items="dossier_fields"
              label="Feld auswählen"
              clearable
              outlined
              :disabled="selectedDossierDefinitions.length == 0"
              @click:clear="queryField = null"
            />
          </v-col>
          <v-col class="pa-2">
            <v-text-field
              v-model="queryField"
              hide-details
              label="und durchsuchen"
              outlined
              :disabled="selectedField == null"
            />
          </v-col>
        </v-row>
      </div>
    </v-card>

    <v-list class="py-0">
      <template v-if="!requestableLoading">
        <div
          v-for="dossier in dossiers"
          :key="dossier.id"
        >
          <dossier-list-item
            :value="dossier"
            :to="{name: 'dossier', params: { dossierId: dossier.id }}"
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
      v-if="!requestableLoading && dossiers && total_pages > 1"
      class="text-center ma-4"
    >
      <v-pagination
        v-model="page"
        circle
        :length="total_pages"
      />
    </div>
    <div v-if="!requestableLoading && dossiers && dossiers.length === 0">
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
