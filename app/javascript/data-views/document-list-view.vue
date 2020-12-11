<script>
import DocumentListItem from 'list-items/document-list-item'

export default {
  name: 'DocumentListView',
  components: { DocumentListItem },
  props: {
    value: {
      type: Array,
      required: true
    },
    divider: {
      type: Boolean,
      default: true
    },
    disabled: Boolean,
    actions: Boolean,
    itemClass: {
      type: String,
      default: 'px-0 '
    }
  }
}
</script>
<template>
  <v-list
    class="py-0"
    color="transparent"
    :disabled="disabled"
  >
    <template v-for="(item, index) in value">
      <document-list-item
        :key="item.id"
        :class="[{'pt-2': index > 0}, itemClass]"
        :value="item"
        :actions="actions"
        class="pb-2"
        @delete="$emit('document-delete', item)"
        @edit="$emit('document-edit', item)"
      />
      <v-divider
        v-if="divider && (index < value.length - 1)"
        :key="`list-divider-${index}`"
      />
    </template>
  </v-list>
</template>
