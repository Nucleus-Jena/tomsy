<script>
export default {
  name: 'ProcessDefinitionsListItem',
  props: {
    value: {
      type: Object,
      required: true
    }
  }
}
</script>
<template>
  <v-list-item
    two-line
    @click="$emit('click', value)"
  >
    <v-list-item-content>
      <v-list-item-title>{{ value.name }}</v-list-item-title>
      <v-list-item-subtitle>
        {{ value.description }}
      </v-list-item-subtitle>
    </v-list-item-content>
  </v-list-item>
</template>
