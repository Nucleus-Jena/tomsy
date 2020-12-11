<script>
import UsersControl from 'controls/users-control'
import SwitchControl from 'controls/switch-control'
import DateControl from 'controls/date-control'

import Ability from 'mixins/models/ability'
import Task from 'mixins/models/task'

export default {
  name: 'TaskSidebarRight',
  components: { UsersControl, SwitchControl, DateControl },
  mixins: [Ability, Task],
  props: {
    task: { type: Object, required: true }
  },
  methods: {
    updateProcess (process) {
      this.$emit('update-process', process)
    }
  }
}
</script>
<template>
  <div>
    <users-control
      v-model="task.assignee"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.tasks.updateAssignee(task.id), mapping: 'assignee'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.users.list()}"
      :disabled="$ability.cannot('update_assignee', task)"
      label="Verantwortlicher"
      single
      indent
      sidebar
      @request-success-data="updateProcess"
    />
    <v-divider />

    <users-control
      v-model="task.contributors"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.tasks.updateContributors(task.id), mapping: 'contributors'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.users.list()}"
      :disabled="$ability.cannot('update_contributors', task)"
      label="Teilnehmer"
      indent
      sidebar
      @request-success-data="updateProcess"
    />
    <v-divider />

    <switch-control
      v-model="task.marked"
      :request-parameter="{method: 'patch', url: $apiEndpoints.tasks.updateMarked(task.id), mapping: 'marked'}"
      :disabled="$ability.cannot('update_marked', task)"
      label="Aufgabe markieren"
      sidebar
    />
    <v-divider />

    <date-control
      v-model="task.dueAt"
      :request-parameter="{method: 'patch', url: $apiEndpoints.tasks.updateDueDate(task.id), mapping: 'due_at'}"
      :disabled="$ability.cannot('update', task)"
      label="Fälligkeitsdatum"
      sidebar
      @request-success-data="updateProcess"
    />
    <v-divider />
  </div>
</template>
