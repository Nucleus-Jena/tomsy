<script>
export default {
  name: 'ActivityHubItemSubject',
  props: {
    user: {
      type: Object,
      required: true
    }
  }
}
</script>
<template functional>
  <router-link
    v-if="!props.user.noaccess && !props.user.deleted"
    :to="{ name: 'user', params: { userId: props.user.id } }"
    class="text-subtitle-2 text--primary object-link"
  >{{ props.user.label }}</router-link>
  <span
    v-else
    class="grey lighten-3 object-link--chip"
  >
    <s v-if="props.user.deleted">{{ props.user.label }}</s>
    <template v-else>{{ props.user.label }}</template>
  </span>
</template>
