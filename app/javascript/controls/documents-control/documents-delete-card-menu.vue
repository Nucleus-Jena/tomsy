<script>
import Request from 'api/request'
import Requestable from 'mixins/requestable'
import Menucardable from 'mixins/menucardable'
import DocumentListItem from 'list-items/document-list-item'

export default {
  name: 'DocumentsDeleteCardMenu',
  components: { DocumentListItem },
  mixins: [Requestable, Menucardable],
  props: {
    value: {
      type: Object,
      default: null
    },
    taskId: {
      type: Number,
      required: true
    }
  },
  computed: {
    requestParameter () {
      return { method: Request.DELETE, url: this.$apiEndpoints.tasks.destroyDocument(this.taskId) }
    }
  },
  methods: {
    onRequestSuccess: function (data) {
      this.closeMenuCard()
      // this.$emit('delete', this.value)

      if (data) {
        this.$emit('request-success-data', data)
      }
    },
    onMenuCardClosed: function () {
      this.resetRequestable()
    }
  }
}
</script>
<template>
  <v-menu
    :attach="attachElement"
    :close-on-click="closeOnClick"
    :close-on-content-click="closeOnContentClick"
    :nudge-bottom="nudgeBottom"
    :value="internalVisible"
    min-width="100%"
    transition="slide-y-transition"
    z-index="1"
    @update:return-value="onMenuReturnValue"
  >
    <v-card
      v-if="value"
      :loading="requestableLoading"
    >
      <div class="pt-4">
        <document-list-item
          :actions="false"
          :linkable="false"
          :value="value"
          class="pb-2 pt-2"
        />
      </div>
      <v-card-actions class="px-4">
        <div
          v-if="baseErrorMessage"
          class="error--text"
        >
          {{ baseErrorMessage }}
        </div>
        <v-spacer />
        <v-btn
          :disabled="requestableLoading"
          color="secondary"
          text
          @click="closeMenuCard"
        >
          Abbrechen
        </v-btn>
        <v-btn
          :disabled="requestableLoading"
          color="error"
          depressed
          @click="request(requestParameter, null,{document_id: value.id})"
        >
          Löschen
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-menu>
</template>
