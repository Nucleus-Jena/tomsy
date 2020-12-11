<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import AvatarComponent from 'components/avatar-component'
import EditorControl from 'controls/editor-control'
import ActivityHubItemComment from './activity-hub-item-comment'
import ActivityHubItemEvent from './activity-hub-item-event'
import User from 'mixins/models/user'
import map from 'lodash/map'

export default {
  name: 'ActivityHub',
  components: { AvatarComponent, EditorControl, ActivityHubItemComment, ActivityHubItemEvent },
  mixins: [Requestable, User],
  props: {
    ...requestablePropFactory().props,
    activities: { type: Object, default: null },
    disabled: Boolean
  },
  data () {
    return {
      selectedTab: null,
      currentComment: null
    }
  },
  computed: {
    commentActivities () {
      if (this.activities && this.activities.comments && this.activities.comments.length) {
        return map(this.activities.comments, element => {
          element.activityType = 'comment'
          element.createdAt = new Date(element.createdAt)
          return element
        })
      }

      return []
    },
    eventActivities () {
      if (this.activities && this.activities.events && this.activities.events.length) {
        return map(this.activities.events, element => {
          element.activityType = 'event'
          element.createdAt = new Date(element.createdAt)
          return element
        })
      }

      return []
    },
    allActivities () {
      return this.commentActivities.concat(this.eventActivities)
    },
    selectedActivities () {
      let activities = []

      switch (this.selectedTab) {
        case 0:
          activities = this.commentActivities
          break
        case 1:
          activities = this.eventActivities
          break
        case 2:
          activities = this.allActivities
          break
      }

      return activities.sort((a, b) => b.createdAt - a.createdAt)
    }
  },
  methods: {
    onRequestSuccess: function (data) {
      this.currentComment = null
      this.$emit('new-comment-success', data)
    },
    scrollToAndShowComments () {
      this.selectedTab = 0
      this.$vuetify.goTo(this, {})
    }
  }
}
</script>
<template>
  <div class="activity-hub">
    <v-tabs v-model="selectedTab">
      <v-tab>
        DISKUSSION
        <v-badge
          class="ml-1"
          :color="selectedTab === 0 ? 'primary' : 'grey lighten-1'"
          :content="commentActivities.length.toString()"
          dense
          inline
        />
      </v-tab>
      <v-tab>
        HISTORIE
        <v-badge
          class="ml-1"
          :color="selectedTab === 1 ? 'primary' : 'grey lighten-1'"
          :content="eventActivities.length.toString()"
          dense
          inline
        />
      </v-tab>
      <v-tab>
        ALLE
        <v-badge
          class="ml-1"
          :color="selectedTab === 2 ? 'primary' : 'grey lighten-1'"
          :content="allActivities.length.toString()"
          dense
          inline
        />
      </v-tab>
    </v-tabs>
    <v-divider class="mb-6" />

    <div
      v-if="selectedTab === 0"
      class="d-flex pa-3"
    >
      <avatar-component
        :text="userInitialsFor($config.current_user)"
        :image="userAvatarImageUrlFor($config.current_user)"
        active
        class="mr-4"
      />

      <div class="flex-grow-1">
        <editor-control
          v-model="currentComment"
          class="mb-3"
          placeholder="Schreib einen Kommentar"
          :loading="requestableLoading"
          :disabled="disabled || requestableLoading"
          :errors="errorMessage"
        />

        <v-btn
          color="primary"
          depressed
          :disabled="disabled || requestableLoading || currentComment === null"
          @click="request(requestParameter, null, currentComment)"
        >
          Kommentieren
        </v-btn>
      </div>
    </div>

    <v-timeline
      v-if="selectedActivities.length"
      class="mt-4 ml-n5 pr-4"
      dense
    >
      <template v-for="activity in selectedActivities">
        <activity-hub-item-comment
          v-if="activity.activityType === 'comment'"
          :key="activity.id"
          :comment="activity"
        />
        <activity-hub-item-event
          v-else
          :key="activity.id"
          :event="activity"
        />
      </template>
    </v-timeline>
  </div>
</template>
