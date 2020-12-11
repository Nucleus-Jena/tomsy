<script>
import ObjectsControl from 'controls/objects-control'
import DossierListItem from 'list-items/dossier-list-item'

export default {
  name: 'DossierControl',
  inject: {
    components: {
      default: {
        ObjectsControl,
        DossierListItem
      }
    }
  },
  model: ObjectsControl.model,
  props: {
    ...ObjectsControl.props
  }
}
</script>
<template functional>
  <component
    :is="injections.components.ObjectsControl"
    v-bind="props"
    v-on="listeners"
  >
    <template #list-item="{item, cssClass, itemClass, indent, itemLink, skeleton, selectable, selected, toggleElement}">
      <component
        :is="injections.components.DossierListItem"
        :key="item.id"
        :class="cssClass"
        :item-class="itemClass"
        :indent="indent"
        :skeleton="skeleton"
        :value="item"
        :item-link="itemLink"
        :selectable="selectable"
        :selected="selected"
        :to="{name: 'dossier', params: { dossierId: item.id }}"
        @click="toggleElement ? toggleElement(item) : {}"
      />
    </template>
  </component>
</template>
