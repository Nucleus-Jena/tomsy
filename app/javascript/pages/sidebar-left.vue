<script>
export default {
  name: 'SidebarLeft',
  props: {
    floating: {
      type: Boolean,
      default: false
    }
  }
}
</script>
<template functional>
  <v-navigation-drawer
    app
    clipped
    left
    permanent
    width="350"
    :floating="props.floating"
  >
    <slot />
  </v-navigation-drawer>
</template>
