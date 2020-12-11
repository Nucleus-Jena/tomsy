<script>
export default {
  name: 'ListItemTemplate',
  props: {
    value: {
      type: Object,
      default: undefined
    },
    twoLine: Boolean,
    threeLine: Boolean,
    selectable: Boolean,
    selected: Boolean,
    skeleton: Boolean,
    skeletonType: {
      type: String,
      default: 'list-item-two-line'
    },
    indent: Boolean,
    dense: {
      type: Boolean,
      default: true
    },
    itemLink: Boolean,
    to: {
      type: [String, Object],
      default: undefined
    },
    itemClass: {
      type: String,
      default: ''
    }
  }
}
</script>
<template functional>
  <v-skeleton-loader
    v-if="props.skeleton"
    :class="{'custom-skeleton-loader--no-indent': !props.indent}"
    :type="props.skeletonType"
    class="custom-skeleton-loader"
  />
  <v-list-item
    v-else
    :class="[{'px-0': !props.indent}, {'py-2': !props.dense}, props.itemClass]"
    :href="!props.selectable && props.itemLink && props.value.href ? props.value.href : undefined"
    :target="!props.selectable && props.itemLink && props.value.href ? '_blank' : undefined"
    :to="!props.selectable && props.to ? props.to : undefined"
    :three-line="props.threeLine"
    :two-line="props.twoLine"
    class="d-flex"
    v-on="listeners.click ? { click: listeners.click } : {}"
  >
    <v-list-item-icon
      v-if="props.selectable"
      class="mr-4 align-self-center"
    >
      <v-icon v-if="props.selected">
        mdi-check
      </v-icon>
    </v-list-item-icon>
    <slot />
  </v-list-item>
</template>
