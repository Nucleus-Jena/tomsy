<script>
import ListItemTemplate from './list-item-template'
import AvatarComponent from 'components/avatar-component'
import Ambition from 'mixins/models/ambition'
import User from 'mixins/models/user'
import { distanceDate } from 'helpers/date'

export default {
  name: 'AmbitionListItem',
  components: { ListItemTemplate, AvatarComponent },
  mixins: [Ambition, User],
  props: {
    ...ListItemTemplate.props
  },
  computed: {
    ambition () {
      return this.value
    },
    stateUpdatedAtDistance () {
      return distanceDate(this.ambitionStateUpdatedAtDate)
    }
  }
}
</script>
<template>
  <list-item-template
    skeleton-type="list-item-avatar-two-line"
    two-line
    v-bind="$props"
    @click="$emit('click', $event)"
  >
    <v-list-item-content>
      <v-list-item-title class="d-flex align-baseline">
        <v-icon
          v-if="ambition.private"
          class="mr-1"
          color="black"
          size="16"
        >
          mdi-lock-outline
        </v-icon>
        <span>{{ ambition.title }}</span>
      </v-list-item-title>
      <v-list-item-subtitle class="custom-meta-list">
        <div>{{ ambitionIdentifier }}</div>
        <div>
          <span :class="ambitionStateColor.text">{{ ambitionStateText }}</span>
          <span>{{ stateUpdatedAtDistance }}</span>
        </div>
        <div>{{ ambitionRunningProcessCountText }}</div>
        <div
          v-if="ambition.commentsCount"
          class="d-flex align-center"
        >
          <v-icon
            class="mr-1"
            size="14"
          >
            mdi-comment-outline
          </v-icon>
          <span>{{ $tc('general.commentsCount', ambition.commentsCount) }}</span>
        </div>
      </v-list-item-subtitle>
      <v-list-item-subtitle
        v-if="$scopedSlots.snippets"
        class="mt-6 ml-4"
      >
        <slot name="snippets" />
      </v-list-item-subtitle>
    </v-list-item-content>

    <avatar-component
      v-if="ambition.assignee"
      :text="userInitialsFor(ambition.assignee)"
      :image="userAvatarImageUrlFor(value.assignee)"
      :tooltip-title="userFullnameFor(ambition.assignee)"
      :tooltip-subtitle="ambition.assignee.email"
      class="mr-2"
      list
    />
  </list-item-template>
</template>
