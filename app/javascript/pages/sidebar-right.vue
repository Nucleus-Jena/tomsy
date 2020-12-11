<script>
export default {
  name: 'SidebarRight'
}
</script>
<template functional>
  <v-navigation-drawer
    app
    clipped
    color="grey lighten-4"
    permanent
    right
    width="320"
  >
    <slot />
  </v-navigation-drawer>
</template>
<style>
    .v-navigation-drawer.v-navigation-drawer--right > .v-navigation-drawer__content {
        padding-left: 1px;
    }
</style>
