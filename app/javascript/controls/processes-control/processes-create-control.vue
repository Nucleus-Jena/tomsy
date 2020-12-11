<script>
import Vue from 'vue'
import Requestable from 'mixins/requestable'
import Menucardable from 'mixins/menucardable'
import Request from 'api/request'
import MenuCardControl from 'controls/menu-card-control'
import MenuCardActionContent from 'controls/menu-card-control/menu-card-action-content'
import ProcessDefinitionsListItem from './process-definitions-list-item'
import debounce from 'lodash/debounce'

export default {
  name: 'ProcessesCreateControl',
  components: { MenuCardControl, MenuCardActionContent, ProcessDefinitionsListItem },
  model: {
    prop: 'visible',
    event: 'visibility-change'
  },
  props: {
    ...Menucardable.props,
    ambitionId: { type: Number, default: undefined },
    predecessorProcessId: { type: Number, default: undefined }
  },
  data () {
    return {
      pageIndex: 0,
      queryText: null,
      queryItems: [],
      queryMaxResults: 10,
      selectedProcessDefinition: null,
      processDefinitionQueryRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (processDefinitions) => {
            this.queryItems = processDefinitions
          }
        }
      }),
      processCreateRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (process) => {
            this.$router.push({ name: 'process', params: { processId: process.id } })
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
    }
  },
  methods: {
    onOpened () {
      this.$emit('opened')
      this.query()
    },
    onClosed () {
      this.resetControl()
      this.$emit('closed')
    },
    selectAndShowProcessDefinitionDetails (processDefinition) {
      this.selectedProcessDefinition = processDefinition
      this.pageIndex = 1
    },
    resetControl () {
      this.pageIndex = 0
      this.queryText = ''

      this.processDefinitionQueryRequestable.cancelRequestable()
      this.processDefinitionQueryRequestable.resetRequestable()

      this.processCreateRequestable.resetRequestable()
    },
    query () {
      this.queryItems = []
      this.processDefinitionQueryRequestable.request(
        { method: Request.GET, url: this.$apiEndpoints.processDefinitions.index() },
        {
          except: [],
          query: this.queryText,
          max_result_count: this.queryMaxResults
        }, null, true)
    },
    queryTextChanged: debounce(function () {
      this.query()
    }, 500),
    createProcess () {
      this.processCreateRequestable.request(
        { method: Request.POST, url: this.$apiEndpoints.processes.create() },
        null,
        {
          process_definition_id: this.selectedProcessDefinition.id,
          ambition_id: this.ambitionId,
          predecessor_process_id: this.predecessorProcessId
        }
      )
    }
  }
}
</script>
<template>
  <menu-card-control
    v-bind="$props"
    :loading="processCreateRequestable.requestableLoading"
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
              :error-messages="processDefinitionQueryRequestable.errorMessage"
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
              <template v-if="!processDefinitionQueryRequestable.requestableLoading">
                <template v-if="queryItems.length > 0">
                  <!--
                  <v-subheader>Empfohlene Maßnahmevorlagen</v-subheader>
                  <process-definitions-list-item :key="pd.id"
                                                 :value="pd"
                                                 @click="showDetails"
                                                 v-for="pd in recommendedProcessDefinitions"/>

                  <v-divider/>

                  <v-subheader>Weitere Maßnahmevorlagen</v-subheader>
                  -->
                  <v-subheader>Verfügbare Maßnahmevorlagen</v-subheader>
                  <process-definitions-list-item
                    v-for="processDefinition in queryItems"
                    :key="processDefinition.id"
                    :value="processDefinition"
                    @click="selectAndShowProcessDefinitionDetails"
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
          :title="selectedProcessDefinition.name"
          :text="selectedProcessDefinition.description"
          primary-btn-text="Starten"
          secondary-btn-text="Zurück"
          :loading="processCreateRequestable.requestableLoading"
          :base-error-message="processCreateRequestable.errorMessage"
          @click-secondary-btn="pageIndex = 0"
          @click-primary-btn="createProcess"
        />
      </v-slide-y-transition>
    </template>
  </menu-card-control>
</template>
