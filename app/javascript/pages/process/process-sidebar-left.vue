<script>
import TaskListItem from 'list-items/task-list-item'
import Process from 'mixins/models/process'

export default {
  name: 'ProcessSidebarLeft',
  components: { TaskListItem },
  mixins: [Process],
  props: {
    process: { type: Object, required: true }
  }
}
</script>
<template>
  <v-list class="pa-0">
    <v-list-item
      class="py-2 d-flex justify-space-between align-start"
      :class="processStateColor.background"
      two-line
      :to="{ name: 'process', params: { processId: process.id } }"
    >
      <v-list-item-content>
        <v-list-item-title class="text-body-2 mb-2 white--text">
          {{ process.definition.name }}
        </v-list-item-title>

        <v-list-item-subtitle class="text-subtitle-1 white--text">
          {{ process.title }}
        </v-list-item-subtitle>
      </v-list-item-content>
    </v-list-item>
    <v-divider />

    <task-list-item
      v-for="task in process.tasks"
      :key="task.id"
      :value="task"
      :to="{name: 'task', params: { processId: task.process.id, taskId: task.id }}"
      :dense="false"
      indent
      sidebar
    />
  </v-list>
</template>
