<script>
import ActivityHubItemEventValue from './activity-hub-item-event-value'
import ActivityHubItemSubject from './activity-hub-item-subject'
import Event from 'mixins/models/event'
import User from 'mixins/models/user'
import { formatDateTime } from 'helpers/date'

export default {
  name: 'ActivityHubItemEvent',
  components: { ActivityHubItemEventValue, ActivityHubItemSubject },
  mixins: [Event, User],
  props: {
    event: { type: Object, required: true },
    showReference: Boolean
  },
  computed: {
    createdAtText () {
      return formatDateTime(new Date(this.event.createdAt))
    }
  }
}
</script>
<template>
  <v-timeline-item
    class="d-flex align-center"
    color="grey lighten-4"
    fill-dot
  >
    <template #icon>
      <v-icon color="grey lighten-1">
        {{ eventIconClass }}
      </v-icon>
    </template>

    <div class="d-flex align-center">
      <div class="flex-grow-1">
        <i18n
          :path="eventMainPath"
          class="text-body-2 text--secondary"
        >
          <template
            v-if="event.user"
            #user
          >
            <activity-hub-item-subject :user="event.user" />
          </template>
          <template #object>
            <template v-for="(element, index) in eventObjectValueElements">
              <activity-hub-item-event-value
                :key="'object-value-' + String(index)"
                :value="element"
              />&#32;
            </template>
          </template>
          <template
            v-if="event.newValue !== null"
            #newValuePart
          >
            <i18n :path="eventNewValuePath">
              <template #newValue>
                <template v-for="(element, index) in eventNewValueElements">
                  <activity-hub-item-event-value
                    :key="'new-value-' + String(index)"
                    :value="element"
                  />&#32;
                </template>
              </template>
            </i18n>
          </template>
          <template
            v-if="event.oldValue !== null && event.newValue !== null"
            #oldValuePart
          >
            <i18n :path="eventOldValuePath">
              <template #oldValue>
                <template v-for="(element, index) in eventOldValueElements">
                  <activity-hub-item-event-value
                    :key="'old-value-' + String(index)"
                    :value="element"
                  />&#32;
                </template>
              </template>
            </i18n>
          </template>
          <template
            v-if="event.newValue === null"
            #deleteValuePart
          >
            <span>{{ $t(eventDeleteValuePath) }}</span>
          </template>
          <template
            v-if="event.newValue !== null"
            #newValue
          >
            <template v-for="(element, index) in eventNewValueElements">
              <activity-hub-item-event-value
                :key="'new-value-' + String(index)"
                :value="element"
              />&#32;
            </template>
          </template>
          <template
            v-if="event.oldValue !== null"
            #oldValue
          >
            <template v-for="(element, index) in eventOldValueElements">
              <activity-hub-item-event-value
                :key="'old-value-' + String(index)"
                :value="element"
              />&#32;
            </template>
          </template>
          <template
            v-if="event.mentioned"
            #mentionedPart
          >
            {{ $t(eventMentionedPath) }}
          </template>
        </i18n>

        <span class="text-body-2 text--secondary"> • {{ createdAtText }}</span>
      </div>
      <div
        v-if="$scopedSlots.actions"
        class="ml-2"
      >
        <slot
          name="actions"
        />
      </div>
    </div>
  </v-timeline-item>
</template>
<style></style>
