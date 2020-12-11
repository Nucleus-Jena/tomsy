<script>
import Ability from 'mixins/models/ability'
import UsersControl from 'controls/users-control'
import SwitchControl from 'controls/switch-control'

export default {
  name: 'AmbitionSidebarRight',
  components: { UsersControl, SwitchControl },
  mixins: [Ability],
  model: {
    prop: 'ambition',
    event: 'change'
  },
  props: {
    ambition: { type: Object, required: true }
  },
  methods: {
    ambitionUpdated (ambition) {
      this.$emit('change', ambition)
    }
  }
}
</script>
<template>
  <div>
    <users-control
      v-model="ambition.assignee"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.ambitions.updateAssignee(ambition.id), mapping: 'assignee'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.users.list()}"
      :disabled="ambition.closed || $ability.cannot('update', ambition)"
      label="Verantwortlicher"
      single
      indent
      sidebar
      @request-success-data="ambitionUpdated"
    />
    <v-divider />

    <switch-control
      v-model="ambition.private"
      :request-parameter="{method: 'patch', url: $apiEndpoints.ambitions.updatePrivateStatus(ambition.id), mapping: 'private'}"
      :disabled="ambition.closed || $ability.cannot('update_private_status', ambition)"
      label="Privat"
      sidebar
      @request-success-data="ambitionUpdated"
    />
    <v-divider />

    <users-control
      v-model="ambition.contributors"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.ambitions.updateContributors(ambition.id), mapping: 'contributors'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.users.list()}"
      :disabled="ambition.closed || $ability.cannot('update_contributors', ambition)"
      label="Teilnehmer"
      indent
      sidebar
      @request-success-data="ambitionUpdated"
    />
    <v-divider />
  </div>
</template>
