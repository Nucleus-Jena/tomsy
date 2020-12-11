<script>
import ObjectListItem from 'list-items/object-list-item'

export default {
  name: 'ObjectListView',
  components: { ObjectListItem },
  props: {
    value: {
      type: Array,
      required: true
    },
    indent: Boolean,
    divider: {
      type: Boolean,
      default: true
    },
    disabled: Boolean,
    itemClass: {
      type: String,
      default: ''
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
      <template>
        <slot
          name="list-item"
          :_item="item"
          :_css-class="['pb-2', {'pt-2': index > 0}]"
          :_item-class="itemClass"
          :_indent="indent"
          _item-link
          :_skeleton="item.skeleton"
        >
          <object-list-item
            :key="item.id"
            :class="['pb-2', {'pt-2': index > 0}]"
            :item-class="itemClass"
            :indent="indent"
            :skeleton="item.skeleton"
            :value="item"
            item-link
          />
        </slot>
        <v-divider
          v-if="divider && (index < value.length - 1)"
          :key="`list-divider-${index}`"
        />
      </template>
    </template>
  </v-list>
</template>
