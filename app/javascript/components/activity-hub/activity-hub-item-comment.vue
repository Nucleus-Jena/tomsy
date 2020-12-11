<script>
import ActivityHubItemEventValue from './activity-hub-item-event-value'
import ActivityHubItemSubject from './activity-hub-item-subject'
import AvatarComponent from 'components/avatar-component'
import EditorContent from 'components/editor-content'
import User from 'mixins/models/user'
import Event from 'mixins/models/event'
import { formatDateTime } from 'helpers/date'

export default {
  name: 'ActivityHubItemComment',
  components: { ActivityHubItemEventValue, AvatarComponent, EditorContent, ActivityHubItemSubject },
  mixins: [Event, User],
  props: {
    comment: {
      type: Object,
      required: true
    },
    event: {
      type: Object,
      default: null
    }
  },
  computed: {
    showReference () {
      return !this.comment.id
    },
    authorReference () {
      return this.showReference ? this.event.user : this.comment.author.reference
    },
    message () {
      return this.comment.message
    },
    itemColor () {
      if (!this.showReference) {
        if (this.$config.isCurrentUser(this.comment.author.reference)) {
          return 'primary'
        } else {
          return 'blue-grey lighten-4'
        }
      } else {
        return 'grey lighten-4'
      }
    },
    createdAtText () {
      return formatDateTime(new Date(this.comment.createdAt || this.event.createdAt))
    },
    commentEventPath () {
      return `event.withSubject.commented.referenced.${this.comment.mentioned ? 'mentioned' : 'normal'}`
    }
  }
}
</script>
<template>
  <v-timeline-item
    class="white--text comment-item"
    :color="itemColor"
    fill-dot
  >
    <template #icon>
      <avatar-component
        v-if="!showReference"
        :text="comment.author.avatar.label"
        :image="comment.author.avatar.url"
      />
      <avatar-component
        v-else
        icon="mdi-comment-text-outline"
      />
    </template>

    <v-card class="elevation-1 flex-grow-1">
      <v-card-title class="d-block text-body-2 text--secondary">
        <activity-hub-item-subject :user="authorReference" />
        <template v-if="showReference">
          <i18n :path="commentEventPath">
            <template #object>
              <template v-for="(element, index) in eventObjectValueElements">
                <activity-hub-item-event-value
                  :key="index"
                  :value="element"
                />&#32;
              </template>
            </template>
          </i18n>
          <span class="text-no-wrap"> • {{ createdAtText }}</span>
        </template>
        <template v-else>
          schrieb am <span class="text-no-wrap">{{ createdAtText }}</span> Uhr
        </template>
      </v-card-title>

      <v-card-text
        v-if="!showReference || !eventObjectValueNoAccess"
        class="text--primary"
      >
        <editor-content :template="message" />
      </v-card-text>
    </v-card>

    <div
      v-if="$scopedSlots.actions"
      class="ml-2"
    >
      <slot
        name="actions"
      />
    </div>
  </v-timeline-item>
</template>
<style>
  .comment-item .v-timeline-item__body {
    display: flex;
    align-items: center;
  }
</style>
