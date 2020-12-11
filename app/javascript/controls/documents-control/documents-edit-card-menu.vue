<script>
import Request from 'api/request'
import Requestable from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Menucardable from 'mixins/menucardable'
import * as documentHelper from 'helpers/document'

export default {
  name: 'DocumentsEditCardMenu',
  mixins: [Requestable, Cacheable, Menucardable],
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
    isLink () {
      return documentHelper.isLink(this.cacheValue)
    },
    isFile () {
      return documentHelper.isFile(this.cacheValue)
    },
    filePlaceholder () {
      return documentHelper.filePlaceholder(this.cacheValue)
    },
    cachedValueChanged: function () {
      if (this.isLink) {
        return this.value.title !== this.cacheValue.title || this.value.linkUrl !== this.cacheValue.linkUrl
      } else {
        return this.value.title !== this.cacheValue.title || this.value.file !== this.cacheValue.file
      }
    },
    isNew () {
      return this.value.id === undefined
    },
    requestParameter () {
      if (this.isNew) {
        return { method: Request.POST, url: this.$apiEndpoints.tasks.createDocument(this.taskId), mapping: this.payloadFromDocument }
      } else {
        return { method: Request.PATCH, url: this.$apiEndpoints.tasks.updateDocument(this.taskId), mapping: this.payloadFromDocument }
      }
    }
  },
  methods: {
    payloadFromDocument (document) {
      const formData = new FormData()

      if (this.value.title !== this.cacheValue.title) formData.append('title', document.title)

      if (this.isLink) {
        if (this.value.linkUrl !== this.cacheValue.linkUrl) formData.append('link_url', document.linkUrl)
      } else {
        if (this.value.file !== this.cacheValue.file) formData.append('file', document.file)
      }

      if (this.isNew) {
        formData.append('data_entity_field', document.dataEntityField)
        formData.append('type', document.type)
      } else {
        formData.append('document_id', document.id)
      }

      return formData
    },
    onRequestSuccess: function (data) {
      this.closeMenuCard()

      if (data) {
        this.$emit('request-success-data', data)
      }
    },
    onMenuCardOpened: function () {
      this.createCacheValue()
    },
    onMenuCardClosed: function () {
      this.resetRequestable()
    },
    cancel: function () {
      this.closeMenuCard()
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
      v-if="cacheValue"
      :loading="requestableLoading"
    >
      <div class="pt-4 px-4">
        <v-text-field
          v-if="isLink"
          v-model="cacheValue.linkUrl"
          :disabled="requestableLoading"
          :error-messages="validationErrorMessageFor('link_url')"
          error-count="5"
          label="Url"
          prepend-icon="mdi-link-variant"
        />

        <v-file-input
          v-else-if="isFile"
          v-model="cacheValue.file"
          :disabled="requestableLoading"
          :error-messages="validationErrorMessageFor('file')"
          :placeholder="filePlaceholder"
          error-count="5"
          label="Datei"
          show-size
        />

        <v-text-field
          v-model="cacheValue.title"
          :disabled="requestableLoading"
          :error-messages="validationErrorMessageFor('title')"
          error-count="5"
          label="Titel"
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
          @click="cancel"
        >
          Abbrechen
        </v-btn>
        <v-btn
          :disabled="!cachedValueChanged || requestableLoading"
          color="primary"
          depressed
          @click="cachedValueChanged && request(requestParameter, null, cacheValue)"
        >
          Speichern
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-menu>
</template>
