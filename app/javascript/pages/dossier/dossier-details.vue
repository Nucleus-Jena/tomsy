<script>
import Breadcrumbs from 'components/breadcrumbs'
import PageDetailHeader from 'components/page-detail-header'
import CustomDialog from 'components/custom-dialog'
import Dossier from 'mixins/models/dossier'
import Request from 'api/request'
import TextControl from 'controls/text-control'
import TextareaControl from 'controls/textarea-control'
import BoolControl from 'controls/bool-control'
import DateControl from 'controls/date-control'
import ProcessListItem from 'list-items/process-list-item'

export default {
  name: 'DossierDetails',
  components: {
    Breadcrumbs,
    PageDetailHeader,
    CustomDialog,
    TextControl,
    TextareaControl,
    BoolControl,
    DateControl,
    ProcessListItem
  },
  mixins: [Dossier],
  inject: {
    helper: {
      default: {
        Request
      }
    }
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      menuOpen: false,
      references: []
    }
  },
  computed: {
    dossier () {
      return this.value
    }
  },
  watch: {
    $props: {
      handler () {
        this.references = []
        if (this.dossier) {
          new Request().get(this.$apiEndpoints.dossiers.getReferences(this.dossier.id))
            .then((data) => {
              this.references = data
            })
            .catch((error) => {
              console.log('get data error:')
              console.log(error)
            })
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    onDossierUpdated (dossier) {
      this.$emit('input', dossier)
    },
    onDossierDeleted () {
      this.$router.replace({ name: 'dossiers' })
    }
  }
}
</script>
<template>
  <div>
    <breadcrumbs
      class="mb-2"
      :items="dossierBreadcrumbs"
    />

    <page-detail-header
      class="mb-7"
      state-text="Erstellt"
      :state-updated-at="new Date(dossier.createdAt)"
      state-color="grey"
    >
      <template #actions="{actionRequest, loading}">
        <v-menu
          v-model="menuOpen"
          left
        >
          <template #activator="{ on }">
            <v-btn
              :disabled="loading"
              color="primary"
              icon
              v-on="on"
            >
              <v-icon>mdi-dots-vertical</v-icon>
            </v-btn>
          </template>

          <v-list>
            <v-list-item @click="$refs.deleteDialog.dialogOpen = true">
              <v-list-item-title>{{ $t('dossier.detailActions.delete') }}</v-list-item-title>
            </v-list-item>

            <custom-dialog
              ref="deleteDialog"
              :title="$t('dossier.deleteDialog.title')"
              :text="$t('dossier.deleteDialog.text')"
              :ok-btn-text="$t('dossier.deleteDialog.buttonOk')"
              ok-btn-color="error"
              @click-ok="actionRequest($apiEndpoints.dossiers.destroy(dossier.id), onDossierDeleted, helper.Request.DELETE)"
              @open="menuOpen = false"
            />
          </v-list>
        </v-menu>
      </template>
    </page-detail-header>

    <h1 class="text-h4 font-weight-light mb-8">
      {{ dossier.title }}
    </h1>

    <template v-for="dataField in dossier.dataFields">
      <text-control
        v-if="dataField.definition.type === 'string'"
        :key="dataField.definition.identifier"
        v-model="dataField.value"
        :label="dataField.definition.label"
        :request-parameter="{method: 'patch', url: $apiEndpoints.dossiers.update(dossier.id), mapping: (data) => { return {'identifier': dataField.definition.identifier, 'value': data}}}"
        @request-success-data="onDossierUpdated"
      />
      <textarea-control
        v-else-if="dataField.definition.type === 'text'"
        :key="dataField.definition.identifier"
        v-model="dataField.value"
        :label="dataField.definition.label"
        :request-parameter="{method: 'patch', url: $apiEndpoints.dossiers.update(dossier.id), mapping: (data) => { return {'identifier': dataField.definition.identifier, 'value': data}}}"
        @request-success-data="onDossierUpdated"
      />
      <bool-control
        v-else-if="dataField.definition.type === 'boolean'"
        :key="dataField.definition.identifier"
        v-model="dataField.value"
        :label="dataField.definition.label"
        :request-parameter="{method: 'patch', url: $apiEndpoints.dossiers.update(dossier.id), mapping: (data) => { return {'identifier': dataField.definition.identifier, 'value': data}}}"
        @request-success-data="onDossierUpdated"
      />
      <date-control
        v-else-if="dataField.definition.type === 'date'"
        :key="dataField.definition.identifier"
        v-model="dataField.value"
        :label="dataField.definition.label"
        :request-parameter="{method: 'patch', url: $apiEndpoints.dossiers.update(dossier.id), mapping: (data) => { return {'identifier': dataField.definition.identifier, 'value': data}}}"
        @request-success-data="onDossierUpdated"
      />
    </template>

    <h3 class="mt-6">
      Referenzen
    </h3>
    <v-list v-if="references && references.length > 0">
      <div
        v-for="(reference, index) in references"
        :key="index"
      >
        <process-list-item
          :value="reference.process"
          :to="{name: 'process', params: { processId: reference.process.id }}"
          indent
          :dense="false"
        >
          <template #references>
            <p
              v-for="field in reference.dossierFields"
              :key="field.name"
              class="mb-2 d-flex"
            >
              <span>{{ field.label }}:&nbsp;</span>
              <template v-for="(referencedDossier, indexValue) in field.value">
                <span
                  :key="`${indexValue}__element`"
                  :class="{'font-weight-bold': referencedDossier.id === dossier.id}"
                >{{ referencedDossier.title }}</span>
                <span
                  v-if="indexValue < field.value.length - 1"
                  :key="`${indexValue}__comma`"
                >,&nbsp;</span>
              </template>
            </p>
          </template>
        </process-list-item>
        <v-divider />
      </div>
    </v-list>
  </div>
</template>
