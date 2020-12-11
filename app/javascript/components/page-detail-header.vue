<script>
import { distanceDate } from 'helpers/date'
import Requestable from 'mixins/requestable'
import Request from 'api/request'

export default {
  name: 'PageDetailHeader',
  mixins: [Requestable],
  props: {
    stateText: {
      type: String,
      required: true
    },
    stateColor: {
      type: String,
      required: true
    },
    stateUpdatedAt: {
      type: Date,
      required: true
    },
    commentsCount: {
      type: Number,
      default: undefined
    }
  },
  data () {
    return {
      onSuccessCallback: null
    }
  },
  computed: {
    stateUpdatedAtDistance () {
      return distanceDate(this.stateUpdatedAt)
    }
  },
  methods: {
    actionRequest (url, onSuccess = null, method = Request.PATCH, params = null, payload = null, useCancelToken = false) {
      if (!this.requestableLoading && Request.METHODS.indexOf(method) !== -1) {
        this.onSuccessCallback = onSuccess
        this.request({ method: method, url: url }, params, payload, useCancelToken)
      }
    },
    onRequestSuccess (data) {
      if (this.onSuccessCallback) this.onSuccessCallback(data)
    }
  }
}
</script>
<template>
  <div
    style="position: relative;"
    :class="{'error--text': hasErrors}"
  >
    <v-divider />
    <v-input
      :error-messages="errorMessage"
      error-count="5"
      class="page-detail-header align-center"
    >
      <v-chip
        :color="stateColor"
        class="white--text"
        label
      >
        {{ stateText }}
      </v-chip>

      <span class="ml-2 text--secondary">{{ stateUpdatedAtDistance }}</span>

      <span
        v-if="commentsCount"
        class="ml-1 text--secondary"
      >
        • <a
          class="u-text-decoration-0"
          @click="$emit('comment-count-click')"
        >{{ commentsCount }} Kommentare</a>
      </span>

      <template #append>
        <slot
          name="actions"
          :action-request="actionRequest"
          :loading="requestableLoading"
        />
      </template>
    </v-input>
    <v-progress-linear
      v-if="requestableLoading"
      absolute
      bottom
      height="2"
      indeterminate
    />
    <v-divider :class="{'inherit-boder-color': hasErrors && !requestableLoading}" />
  </div>
</template>
<style>
    .inherit-boder-color {
        border-color: inherit !important;
    }
    .page-detail-header > .v-input__control > .v-input__slot {
        margin-top: 8px;
    }
    .page-detail-header:not(.v-input--has-state) > .v-input__control > .v-messages {
        display: none;
    }
</style>
