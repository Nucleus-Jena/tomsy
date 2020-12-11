<script>
import Vue from 'vue'
import Requestable from 'mixins/requestable'
import Menucardable from 'mixins/menucardable'
import Request from 'api/request'
import MenuCardControl from 'controls/menu-card-control'
import MenuCardActionContent from 'controls/menu-card-control/menu-card-action-content'
import DossierDefinitionListItem from 'list-items/dossier-definition-list-item'
import debounce from 'lodash/debounce'
import reduce from 'lodash/reduce'
import DataControl from 'controls/data-control'

export default {
  name: 'DossierCreateControl',
  components: {
    MenuCardControl,
    MenuCardActionContent,
    DossierDefinitionListItem,
    DataControl
  },
  model: {
    prop: 'visible',
    event: 'visibility-change'
  },
  props: {
    ...Menucardable.props
  },
  data () {
    return {
      pageIndex: 0,
      queryText: null,
      queryItems: [],
      queryMaxResults: 10,
      selectedDossierDefinition: null,
      dossier: null,
      dossierDefinitionQueryRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (dossierDefinitions) => {
            this.queryItems = dossierDefinitions
          }
        }
      }),
      dossierNewRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (dossier) => {
            this.dossier = dossier
          }
        }
      }),
      dossierCreateRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (dossier) => {
            this.$router.push({ name: 'dossier', params: { dossierId: dossier.id } })
          }
        }
      })
    }
  },
  computed: {
    hintMessage () {
      if (this.queryItems.length < this.queryMaxResults) {
        return null
      } else {
        return 'Mehr Ergebnisse verfügbar. Bitte verfeinern Sie Ihre Suche.'
      }
    },
    dossierIsValid () {
      if (this.dossier) {
        return reduce(this.dossier.dataFields, function (result, field) {
          if (field.definition.required) result &= !(field.value === null || field.value === undefined || field.value === '')
          return result
        }, true)
      }

      return false
    }
  },
  methods: {
    onOpened () {
      this.$emit('opened')
      this.query()
    },
    onClosed () {
      this.pageIndex = 0
      this.queryText = ''
      this.dossier = null
      this.dossierDefinitionQueryRequestable.cancelRequestable()
      this.dossierDefinitionQueryRequestable.resetRequestable()
      this.dossierNewRequestable.cancelRequestable()
      this.dossierNewRequestable.resetRequestable()
      this.dossierCreateRequestable.resetRequestable()

      this.$emit('closed')
    },
    showDossierDefinitionListPage () {
      this.dossierNewRequestable.cancelRequestable()
      this.dossierNewRequestable.resetRequestable()
      this.dossier = null

      this.pageIndex = 0
    },
    showCreateDossierPage (dossierDefinition) {
      this.selectedDossierDefinition = dossierDefinition
      this.dossierNewRequestable.request(
        { method: Request.GET, url: this.$apiEndpoints.dossiers.new() },
        {
          dossier_definition_id: this.selectedDossierDefinition.id
        }, null, true)
      this.pageIndex = 1
    },
    query () {
      this.queryItems = []
      this.dossierDefinitionQueryRequestable.request(
        { method: Request.GET, url: this.$apiEndpoints.dossierDefinitions.index() },
        {
          except: [],
          query: this.queryText,
          max_result_count: this.queryMaxResults
        }, null, true)
    },
    queryTextChanged: debounce(function () {
      this.query()
    }, 500),
    createDossier () {
      this.dossierCreateRequestable.request(
        { method: Request.POST, url: this.$apiEndpoints.dossiers.create() },
        null,
        {
          dossier_definition_id: this.selectedDossierDefinition.id,
          field_data: reduce(this.dossier.dataFields, function (result, field) {
            result[field.definition.identifier] = field.value
            return result
          }, {})
        }
      )
    }
  }
}
</script>
<template>
  <menu-card-control
    v-bind="$props"
    :loading="dossierCreateRequestable.requestableLoading"
    @menu-card-opened="onOpened"
    @menu-card-closed="onClosed"
    @visibility-change="$emit('visibility-change', false)"
  >
    <template
      v-if="$scopedSlots.activator"
      #activator="{ on }"
    >
      <slot
        name="activator"
        :on="on"
      />
    </template>

    <template #content="{}">
      <v-slide-y-transition mode="out-in">
        <div
          v-if="pageIndex === 0"
          key="0"
        >
          <div class="pt-4">
            <v-text-field
              v-model="queryText"
              :error-messages="dossierDefinitionQueryRequestable.errorMessage"
              :hint="hintMessage"
              autofocus
              class="mx-4"
              clearable
              label="Suche"
              outlined
              persistent-hint
              @input="queryTextChanged"
            />

            <v-divider />

            <v-list
              class="u-scroll-y py-0"
              max-height="400"
            >
              <template v-if="!dossierDefinitionQueryRequestable.requestableLoading">
                <template v-if="queryItems.length > 0">
                  <v-subheader>Verfügbare Dossiervorlagen</v-subheader>
                  <dossier-definition-list-item
                    v-for="dossierDefinition in queryItems"
                    :key="dossierDefinition.id"
                    :value="dossierDefinition"
                    indent
                    :dense="false"
                    @click="showCreateDossierPage"
                  />
                </template>
                <v-list-item v-else>
                  <v-list-item-content class="text-center">
                    Keine Ergebnisse
                  </v-list-item-content>
                </v-list-item>
              </template>
              <v-list-item v-else>
                <v-list-item-content class="text-center">
                  <v-progress-circular
                    color="primary"
                    indeterminate
                  />
                </v-list-item-content>
              </v-list-item>
            </v-list>
          </div>
        </div>
        <menu-card-action-content
          v-if="pageIndex === 1"
          key="1"
          :title="selectedDossierDefinition.label"
          :text="selectedDossierDefinition.description"
          primary-btn-text="Erstellen"
          secondary-btn-text="Zurück"
          :loading="dossierCreateRequestable.requestableLoading"
          :primary-btn-disabled="!dossierIsValid"
          :base-error-message="dossierCreateRequestable.baseErrorMessage"
          @click-secondary-btn="showDossierDefinitionListPage"
          @click-primary-btn="createDossier"
        >
          <div class="mt-8">
            <template v-if="!dossierNewRequestable.requestableLoading && dossier">
              <template v-for="dataField in dossier.dataFields">
                <data-control
                  :key="dataField.definition.identifier"
                  v-model="dataField.value"
                  :type="dataField.definition.type"
                  :label="dataField.definition.label"
                  :loading="dossierCreateRequestable.requestableLoading"
                  :hint="dataField.definition.required ? 'Erforderlich': undefined"
                  persistent-hint
                  :error-messages="dossierCreateRequestable.validationErrorMessageFor(`field_${dataField.definition.identifier}`)"
                />
              </template>
            </template>
            <div
              v-else
              class="text-center"
            >
              <v-progress-circular
                color="primary"
                indeterminate
              />
            </div>
          </div>
        </menu-card-action-content>
      </v-slide-y-transition>
    </template>
  </menu-card-control>
</template>
