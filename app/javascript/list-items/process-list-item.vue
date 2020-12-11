<script>
import ListItemTemplate from './list-item-template'
import AvatarComponent from 'components/avatar-component'
import Process from 'mixins/models/process'
import User from 'mixins/models/user'
import { distanceDate } from 'helpers/date'
import omit from 'lodash/omit'

export default {
  name: 'ProcessListItem',
  components: { ListItemTemplate, AvatarComponent },
  mixins: [Process, User],
  props: {
    ...omit(ListItemTemplate.props, ['skeletonType', 'threeLine', 'twoLine', 'disabled'])
  },
  computed: {
    process () {
      return this.value
    },
    stateUpdatedAtDistance () {
      return distanceDate(this.processStateUpdatedAtDate)
    }
  }
}
</script>
<template>
  <list-item-template
    skeleton-type="list-item-three-line"
    v-bind="$props"
    :to="processNoAccess ? undefined : to"
    @click="$emit('click', $event)"
  >
    <v-list-item-content>
      <v-list-item-subtitle class="text-body-2 mb-2 px-0">
        {{ processNoAccess ? 'Bei Bedarf Verantwortlichen kontaktieren' : value.definition.name }}
      </v-list-item-subtitle>

      <v-list-item-title class="text-subtitle-1 d-flex align-center">
        <v-icon
          v-if="!processNoAccess && value.private"
          class="mr-1"
          color="black"
          size="16"
        >
          mdi-lock-outline
        </v-icon>
        <span :class="{ 'text--disabled': processNoAccess }">{{ processNoAccess ? 'Maßnahme - derzeit kein Zugriff' : value.title }}</span>
      </v-list-item-title>

      <v-list-item-subtitle class="custom-meta-list">
        <div>{{ processIdentifier }}</div>
        <template v-if="!processNoAccess">
          <div>
            <span :class="processStateColor.text">{{ processStateText }}</span>
            <span>{{ stateUpdatedAtDistance }}</span>
          </div>
          <div
            v-if="value.tasksDueCount"
            class="error--text"
          >
            {{ $tc('process.tasksDueCount', process.tasksDueCount) }}
          </div>
          <div
            v-if="process.commentsCount"
            class="d-flex align-center"
          >
            <v-icon
              class="mr-1"
              size="14"
            >
              mdi-comment-outline
            </v-icon>
            <span>{{ $tc('general.commentsCount', process.commentsCount) }}</span>
          </div>
        </template>
      </v-list-item-subtitle>
      <v-list-item-subtitle
        v-if="$scopedSlots.snippets"
        class="mt-6 ml-4"
      >
        <slot name="snippets" />
      </v-list-item-subtitle>
      <v-list-item-subtitle
        v-if="$scopedSlots.references"
        class="mt-6 ml-4"
      >
        <slot name="references" />
      </v-list-item-subtitle>
    </v-list-item-content>

    <avatar-component
      v-if="value.assignee"
      :text="userInitialsFor(value.assignee)"
      :image="userAvatarImageUrlFor(value.assignee)"
      :tooltip-title="userFullnameFor(value.assignee)"
      :tooltip-subtitle="value.assignee.email"
      class="mr-2 align-self-start"
      list
    />
  </list-item-template>
</template>
