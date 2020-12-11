<script>
export default {
  name: 'ActivityHubItemEventValue',
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    route () {
      switch (this.value.data.type) {
        case 'user': return { name: 'user', params: { userId: this.value.data.id } }
        case 'ambition': return { name: 'ambition', params: { ambitionId: this.value.data.id } }
        case 'process': return { name: 'process', params: { processId: this.value.data.id } }
        case 'task': return { name: 'single_task', params: { taskId: this.value.data.id } }
        default: return null
      }
    }
  }
}
</script>
<template>
  <router-link
    v-if="value.type === 'reference' && !value.data.noaccess && !value.data.deleted"
    :to="route"
    class="blue lighten-5 primary--text object-link object-link--chip"
  >{{ value.data.label }}</router-link>
  <span
    v-else-if="value.type === 'reference' && (value.data.noaccess || value.data.deleted)"
    class="grey lighten-3 object-link--chip"
  >
    <s v-if="value.data.deleted">{{ value.data.label }}</s>
    <template v-else>{{ value.data.label }}</template>
  </span>
  <span v-else-if="value.type === 'text'">{{ value.text }}</span>
  <span
    v-else-if="value.type === 'value'"
    class="text--primary"
  >{{ value.text }}</span>
</template>
