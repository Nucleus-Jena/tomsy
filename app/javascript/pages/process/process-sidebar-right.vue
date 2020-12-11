<script>
import UsersControl from 'controls/users-control'
import SwitchControl from 'controls/switch-control'
import ObjectsControl from 'controls/objects-control'
import ObjectListItem from 'list-items/object-list-item'

import Ability from 'mixins/models/ability'
import Ambition from 'mixins/models/ambition'

export default {
  name: 'ProcessSidebarRight',
  components: { UsersControl, SwitchControl, ObjectsControl, ObjectListItem },
  mixins: [Ability, Ambition],
  model: {
    prop: 'process',
    event: 'update-process'
  },
  props: {
    process: { type: Object, required: true }
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
      v-model="process.assignee"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.processes.updateAssignee(process.id), mapping: 'assignee'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.users.list()}"
      :disabled="$ability.cannot('update_assignee', process)"
      label="Verantwortlicher"
      single
      indent
      sidebar
      @request-success-data="updateProcess"
    />
    <v-divider />

    <switch-control
      v-model="process.private"
      :request-parameter="{method: 'patch', url: $apiEndpoints.processes.updatePrivateStatus(process.id), mapping: 'private'}"
      :disabled="$ability.cannot('update_private_status', process)"
      label="Privat"
      sidebar
      @request-success-data="updateProcess"
    />
    <v-divider />

    <users-control
      v-model="process.contributors"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.processes.updateContributors(process.id), mapping: 'contributors'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.users.list()}"
      :disabled="$ability.cannot('update_contributors', process)"
      label="Teilnehmer"
      indent
      sidebar
      @request-success-data="updateProcess"
    />
    <v-divider />

    <objects-control
      v-model="process.ambitions"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.processes.updateAmbitions(process.id), mapping: 'ambitions'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.ambitions.list()}"
      :disabled="$ability.cannot('update', process)"
      label="Ziele"
      :divider="false"
      indent
      sidebar
    >
      <template #list-item="{item, indent, itemLink, selectable, selected, toggleElement}">
        <object-list-item
          :key="item.id"
          :indent="indent"
          :item-link="itemLink"
          :selectable="selectable"
          :selected="selected"
          :skeleton="item.skeleton"
          :value="ambitionBusinessObjectFor(item)"
          :to="{name: 'ambition', params: { ambitionId: item.id }}"
          @click="toggleElement ? toggleElement(item) : {}"
        />
      </template>
    </objects-control>
    <v-divider />
  </div>
</template>
