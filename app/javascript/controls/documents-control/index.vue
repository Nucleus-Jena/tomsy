<script>
import DocumentListView from 'data-views/document-list-view'
import DocumentsEditCardMenu from './documents-edit-card-menu'
import DocumentsDeleteCardMenu from './documents-delete-card-menu'
import { createLinkDocument, createFileDocument } from 'helpers/document'

export default {
  name: 'DocumentsControl',
  components: { DocumentListView, DocumentsEditCardMenu, DocumentsDeleteCardMenu },
  model: {
    prop: 'value',
    event: 'change'
  },
  props: {
    label: {
      type: String,
      default: ''
    },
    value: {
      type: Array,
      default: undefined
    },
    taskId: {
      type: Number,
      required: true
    },
    dataEntityField: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      showEditCardMenu: false,
      showDeleteCardMenu: false,
      currentValue: null
    }
  },
  computed: {
    inEditState: function () {
      return this.showEditCardMenu || this.showDeleteCardMenu
    }
  },
  methods: {
    createLink: function () {
      this.editItem(createLinkDocument(this.dataEntityField))
    },
    createFile: function () {
      this.editItem(createFileDocument(this.dataEntityField))
    },
    editItem: function (item) {
      this.currentValue = item
      this.showEditCardMenu = true
    },
    deleteItem: function (item) {
      this.currentValue = item
      this.showDeleteCardMenu = true
    },
    onRequestSuccessData (data) {
      this.$emit('request-success-data', data)
    }
  }
}
</script>
<template>
  <v-card
    ref="container"
    class="custom-control"
    flat
  >
    <documents-edit-card-menu
      v-model="showEditCardMenu"
      :attach="$refs.container"
      :nudge-bottom="52"
      :value="currentValue"
      :task-id="taskId"
      @request-success-data="onRequestSuccessData"
    />

    <documents-delete-card-menu
      v-model="showDeleteCardMenu"
      :attach="$refs.container"
      :nudge-bottom="52"
      :value="currentValue"
      :task-id="taskId"
      @request-success-data="onRequestSuccessData"
    />

    <v-card-title class="px-0 py-3 flex-nowrap">
      <div class="mr-auto text-body-1 text--secondary text-truncate">
        {{ label }}
      </div>
      <v-btn
        :disabled="inEditState"
        color="primary"
        small
        text
        @click.stop="createLink()"
      >
        Link hinzufügen
      </v-btn>
      <v-btn
        :disabled="inEditState"
        color="primary"
        small
        text
        @click.stop="createFile()"
      >
        Datei hinzufügen
      </v-btn>
    </v-card-title>

    <document-list-view
      :value="value"
      :disabled="inEditState"
      item-class="px-0"
      actions
      @document-delete="deleteItem"
      @document-edit="editItem"
    />

    <v-divider class="custom-control__divider" />

    <div class="v-messages theme--light error--text mt-2">
      <div class="v-messages__wrapper">
        <div class="v-messages__message" />
      </div>
    </div>
  </v-card>
</template>
