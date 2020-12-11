<script>
export default {
  name: 'Mention',
  props: {
    mId: {
      type: String,
      required: true
    },
    mType: {
      type: String,
      required: true
    },
    noaccess: Boolean,
    deleted: Boolean
  },
  computed: {
    route () {
      switch (this.mType) {
        case 'user': return { name: 'user', params: { userId: this.mId } }
        case 'ambition': return { name: 'ambition', params: { ambitionId: this.mId } }
        case 'process': return { name: 'process', params: { processId: this.mId } }
        case 'task': return { name: 'single_task', params: { taskId: this.mId } }
        default: return null
      }
    }
  }
}
</script>
<template>
  <router-link
    v-if="!noaccess && !deleted"
    :to="route"
    class="blue lighten-5 primary--text object-link object-link--chip"
  ><slot /></router-link>
  <span
    v-else
    class="grey lighten-3 object-link--chip"
  >
    <s v-if="deleted"><slot /></s>
    <slot v-else />
  </span>
</template>
