<script>
import ListItemTemplate from './list-item-template'

export default {
  name: 'DossierDefinitionListItem',
  components: { ListItemTemplate },
  props: {
    ...ListItemTemplate.props
  }
}
</script>
<template>
  <list-item-template
    skeleton-type="list-item-avatar-two-line"
    two-line
    v-bind="$props"
    @click="$emit('click', value)"
  >
    <v-list-item-content>
      <v-list-item-title>{{ value.label }}</v-list-item-title>
      <v-list-item-subtitle>{{ value.description }}</v-list-item-subtitle>
    </v-list-item-content>
  </list-item-template>
</template>
