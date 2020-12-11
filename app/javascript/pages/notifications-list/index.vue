<script>
import Vue from 'vue'
import PageContent from '../page-content'
import ActivityHubItemComment from 'components/activity-hub/activity-hub-item-comment'
import ActivityHubItemEvent from 'components/activity-hub/activity-hub-item-event'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import PageTitle from 'mixins/page-title'

export default {
  name: 'NotificationsListPage',
  components: { PageContent, ActivityHubItemComment, ActivityHubItemEvent },
  mixins: [Requestable, PageTitle],
  data () {
    return {
      showUnmarked: true,
      counts: {
        unmarked: null,
        marked: null
      },
      notifications: [],
      notificationMarkAllRequestable: new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (notifications) => {
            this.onRequestSuccess(notifications)
          }
        }
      })
    }
  },
  computed: {
    pageTitleParts () {
      return ['Benachrichtigungen']
    },
    countStrings () {
      return {
        unmarked: this.counts.unmarked === null ? '' : this.counts.unmarked.toString(),
        marked: this.counts.marked === null ? '' : this.counts.marked.toString()
      }
    }
  },
  methods: {
    fetchData (index) {
      if (this.hasErrors) this.resetRequestable()
      this.showUnmarked = (index === 0)
      this.request({ method: Request.GET, url: this.$apiEndpoints.notifications.index() },
        { marked: this.showUnmarked ? 0 : 1 }, null, true)
    },
    onRequestSuccess: function (data) {
      this.counts.unmarked = data.counts.unmarked
      this.counts.marked = data.counts.marked
      this.notifications = data.elements
    },
    sendMarkRequest (id) {
      const requestable = new (Vue.extend(Requestable))({
        methods: {
          onRequestSuccess: (notifications) => {
            this.onRequestSuccess(notifications)
          }
        }
      })

      requestable.request({ method: Request.PATCH, url: this.$apiEndpoints.notifications.mark(id) })
    },
    sendMarkAllRequest () {
      this.notificationMarkAllRequestable.request({ method: Request.PATCH, url: this.$apiEndpoints.notifications.mark_all() })
    }
  }
}
</script>
<template>
  <page-content
    class="page-notifications-list"
    :error="error"
    @reload="fetchData(showUnmarked ? 0 : 1)"
  >
    <div class="d-flex justify-space-between mt-4">
      <h1 class="text-h4 font-weight-light pt-1">
        Benachrichtigungen
      </h1>

      <template>
        <v-btn
          v-if="showUnmarked"
          color="primary"
          text
          @click="sendMarkAllRequest"
        >
          Alle Archivieren
        </v-btn>
      </template>
    </div>

    <v-card
      class="mt-4"
      elevation="0"
      outlined
    >
      <v-tabs
        class="d-flex"
        @change="fetchData"
      >
        <v-tab>
          Neu
          <v-badge
            class="ml-1"
            :content="countStrings.unmarked"
            dense
            inline
          />
        </v-tab>
        <v-tab>
          Archiviert
          <v-badge
            class="ml-1"
            color="grey lighten-1"
            :content="countStrings.marked"
            dense
            inline
          />
        </v-tab>
      </v-tabs>
    </v-card>

    <v-timeline
      v-if="!requestableLoading && !hasErrors && notifications.length"
      class="ml-n5"
      dense
    >
      <template v-for="notification in notifications">
        <activity-hub-item-comment
          v-if="notification.event.type === 'commented'"
          :key="notification.id"
          :comment="notification.event.newValue"
          :event="notification.event"
        >
          <template #actions>
            <v-btn
              v-if="showUnmarked"
              color="primary"
              text
              @click="sendMarkRequest(notification.id)"
            >
              Archivieren
            </v-btn>
          </template>
        </activity-hub-item-comment>
        <activity-hub-item-event
          v-else
          :key="notification.id"
          :event="notification.event"
          show-reference
        >
          <template #actions>
            <v-btn
              v-if="showUnmarked"
              color="primary"
              text
              @click="sendMarkRequest(notification.id)"
            >
              Archivieren
            </v-btn>
          </template>
        </activity-hub-item-event>
      </template>
    </v-timeline>
  </page-content>
</template>
