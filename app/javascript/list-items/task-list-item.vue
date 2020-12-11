<script>
import ListItemTemplate from './list-item-template'
import AvatarComponent from 'components/avatar-component'
import Task from 'mixins/models/task'
import Process from 'mixins/models/process'
import User from 'mixins/models/user'
import { distanceDate, formatDateTime } from 'helpers/date'
import { isPast } from 'date-fns'

export default {
  name: 'TaskListItem',
  components: { ListItemTemplate, AvatarComponent },
  mixins: [Task, Process, User],
  props: {
    ...ListItemTemplate.props,
    sidebar: Boolean
  },
  computed: {
    task () {
      return this.value
    },
    process () {
      return this.task.process
    },
    stateUpdatedAtText () {
      return formatDateTime(this.taskStateUpdatedAtDate)
    },
    stateUpdatedAtDistance () {
      return distanceDate(this.taskStateUpdatedAtDate)
    },
    isDue () {
      return isPast(this.taskDueAtDate)
    },
    showDueDate () {
      return this.task.dueAt && (this.taskIsStarted || (this.taskIsCreated && this.processIsRunning))
    }
  }
}
</script>
<template>
  <list-item-template
    skeleton-type="list-item-avatar-two-line"
    two-line
    v-bind="$props"
    :item-class="sidebar ? 'pl-2' : undefined"
    @click="$emit('click', $event)"
  >
    <div
      v-if="sidebar"
      class="task-spacer"
    >
      |
    </div>

    <v-list-item-content :class="{'mx-2': sidebar}">
      <v-list-item-subtitle
        v-if="!sidebar"
        class="text-body-2 mb-2"
      >
        {{ task.process.definition.name }} > {{ task.process.title }}
      </v-list-item-subtitle>
      <v-list-item-title class="text-subtitle-1">
        {{ task.definition.name }}
      </v-list-item-title>
      <v-list-item-subtitle class="custom-meta-list">
        <div>{{ taskIdentifier }}</div>

        <div v-if="sidebar">
          <v-tooltip bottom>
            <template #activator="{ on }">
              <span
                :class="taskStateColor.text"
                v-on="on"
              >{{ taskStateText }}</span>
            </template>
            <span>{{ stateUpdatedAtText }}</span>
          </v-tooltip>
        </div>
        <div v-else>
          <span :class="taskStateColor.text">{{ taskStateText }}</span>
          <span>{{ stateUpdatedAtDistance }}</span>
        </div>

        <div
          v-if="sidebar && task.commentsCount"
          class="d-flex align-center"
        >
          <v-icon
            class="mr-1"
            size="14"
          >
            mdi-comment-outline
          </v-icon>
          <span>{{ task.commentsCount }}</span>
        </div>
        <div
          v-if="!sidebar && task.commentsCount"
          class="d-flex align-center"
        >
          <v-icon
            class="mr-1"
            size="14"
          >
            mdi-comment-outline
          </v-icon>
          <span>{{ $tc('general.commentsCount', task.commentsCount) }}</span>
        </div>

        <template v-if="showDueDate">
          <div
            v-if="sidebar && task.dueAt"
            class="d-flex align-center"
          >
            <v-tooltip bottom>
              <template #activator="{ on }">
                <v-icon
                  :color="isDue ? 'red' : null"
                  size="14"
                  v-on="on"
                >
                  mdi-alarm
                </v-icon>
              </template>
              <span>{{ taskDueDistanceText }}</span>
            </v-tooltip>
          </div>
          <div
            v-if="!sidebar && task.dueAt"
            class="d-flex align-center"
            :class="{'red--text': isDue}"
          >
            <v-icon
              class="mr-1"
              :color="isDue ? 'red' : null"
              size="14"
            >
              mdi-alarm
            </v-icon>
            <span>{{ taskDueDistanceText }}</span>
          </div>
        </template>
      </v-list-item-subtitle>
      <v-list-item-subtitle
        v-if="$scopedSlots.snippets"
        class="mt-6 ml-4"
      >
        <slot name="snippets" />
      </v-list-item-subtitle>
    </v-list-item-content>

    <avatar-component
      v-if="task.assignee"
      :text="userInitialsFor(task.assignee)"
      :image="userAvatarImageUrlFor(task.assignee)"
      :tooltip-title="userFullnameFor(task.assignee)"
      :tooltip-subtitle="task.assignee.email"
      class="mr-2"
      list
    />

    <div
      v-if="sidebar"
      class="task_list-item-border"
      :class="taskStateColor.background"
    />
  </list-item-template>
</template>
<style scoped>
    .task_list-item-border {
        position: absolute;
        width: 6px;
        top: 0;
        bottom: 0;
        right: 0;
    }
</style>
