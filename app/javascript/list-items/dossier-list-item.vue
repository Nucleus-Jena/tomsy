<script>
import ListItemTemplate from './list-item-template'

export default {
  name: 'DossierListItem',
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
    @click="$emit('click', $event)"
  >
    <v-list-item-content>
      <template v-if="!value.deleted">
        <v-list-item-title>{{ value.title }}</v-list-item-title>
        <v-list-item-subtitle class="custom-meta-list">
          {{ value.subtitle }}
        </v-list-item-subtitle>
      </template>
      <template v-else>
        <v-list-item-title class="text--disabled">
          Gelöschtes Dossier
        </v-list-item-title>
        <v-list-item-subtitle class="custom-meta-list text--disabled">
          {{ `*${value.id}` }}
        </v-list-item-subtitle>
      </template>
      <v-list-item-subtitle
        v-if="$scopedSlots.snippets"
        class="mt-6 ml-4"
      >
        <slot name="snippets" />
      </v-list-item-subtitle>
    </v-list-item-content>
    <v-list-item-action class="align-self-start">
      <v-list-item-action-text>{{ value.definition_label }}</v-list-item-action-text>
    </v-list-item-action>
  </list-item-template>
</template>
