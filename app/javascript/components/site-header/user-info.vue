<script>
import Requestable from 'mixins/requestable'
import Request from 'api/request'

export default {
  name: 'UserInfo',
  mixins: [Requestable],
  data () {
    return {
      countNewNotifications: '?',
      countOpenUserAssignedTasks: '?',
      hasDueOpenUserAssignedTasks: false
    }
  },
  channels: {
    UserChannel: {
      connected () { console.log('connected to UserChannel via vue') },
      rejected () {},
      received (data) {
        this.countNewNotifications = data.count_new_notifications
        this.countOpenUserAssignedTasks = data.count_open_user_assigned_tasks
        this.hasDueOpenUserAssignedTasks = data.has_due_open_user_assigned_tasks
      },
      disconnected () {}
    }
  },
  computed: {
    userAssignedOpenTaskCountBadgeColor: function () {
      return this.hasDueOpenUserAssignedTasks ? 'error' : 'primary'
    }
  },
  mounted () {
    this.$cable.subscribe({
      channel: 'UserChannel'
    })
  },
  created () {
    this.request({ method: Request.GET, url: this.$apiEndpoints.users.info(this.$config.current_user.id) },
      null, null, true)
  },
  methods: {
    onRequestSuccess (data) {
      this.countNewNotifications = data.count_new_notifications
      this.countOpenUserAssignedTasks = data.count_open_user_assigned_tasks
      this.hasDueOpenUserAssignedTasks = data.has_due_open_user_assigned_tasks
    },
    onRequestError (errors) {
      this.countNewNotifications = '?'
      this.countOpenUserAssignedTasks = '?'
      this.hasDueOpenUserAssignedTasks = false
      console.log('get data error:')
      console.log(errors)
    }
  }
}
</script>
<template>
  <div class="d-flex mr-10">
    <v-btn
      id="user-notifications-button"
      :to="{name: 'notifications'}"
      class="mr-4"
      icon
    >
      <v-badge
        v-if="countNewNotifications > 0"
        offset-x="7"
        offset-y="7"
      >
        <template #badge>
          <span>{{ countNewNotifications }}</span>
        </template>
        <v-icon>mdi-bell</v-icon>
      </v-badge>
      <v-icon v-else>
        mdi-bell
      </v-icon>
    </v-btn>

    <v-btn
      id="user-tasks-button"
      class="mr-4"
      icon
      :to="{name: 'tasks', query: { assignees: [this.$config.current_user.id] }}"
      exact
    >
      <v-badge
        v-if="countOpenUserAssignedTasks > 0"
        :color="userAssignedOpenTaskCountBadgeColor"
        offset-x="7"
        offset-y="7"
      >
        <template #badge>
          <span>{{ countOpenUserAssignedTasks }}</span>
        </template>
        <v-icon>mdi-account</v-icon>
      </v-badge>
      <v-icon v-else>
        mdi-account
      </v-icon>
    </v-btn>
  </div>
</template>
