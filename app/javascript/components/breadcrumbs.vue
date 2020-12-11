<script>
export default {
  name: 'Breadcrumbs',
  props: {
    items: {
      type: Array,
      required: true
    }
  }
}
</script>
<template functional>
  <v-breadcrumbs
    class="px-0 py-2"
    divider=">"
    :items="props.items"
  >
    <template #item="{ item }">
      <v-breadcrumbs-item
        :disabled="item.disabled"
        exact
        :to="item.to"
      >
        {{ item.text }}
      </v-breadcrumbs-item>
    </template>
  </v-breadcrumbs>
</template>
