<script>
import ObjectsControl from 'controls/objects-control'
import ObjectListItem from 'list-items/object-list-item'
import AvatarComponent from 'components/avatar-component'
import User from 'mixins/models/user'

export default {
  name: 'UsersControl',
  inject: {
    components: {
      default: {
        ObjectsControl,
        ObjectListItem,
        AvatarComponent
      }
    },
    helper: {
      default: {
        user: User.methods
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
    <template
      v-if="!props.single"
      #list="{items}"
    >
      <div class="d-flex flex-wrap px-4 py-2">
        <component
          :is="injections.components.AvatarComponent"
          v-for="item in items"
          :key="item.id"
          :skeleton="item.skeleton"
          :text="injections.helper.user.userInitialsFor(item)"
          :image="injections.helper.user.userAvatarImageUrlFor(item)"
          :tooltip-subtitle="item.email"
          :tooltip-title="injections.helper.user.userFullnameFor(item)"
          class="mr-1 mb-2"
        />
      </div>
    </template>
    <template #list-item="{item, cssClass, itemClass, indent, itemLink, skeleton, selectable, selected, toggleElement}">
      <component
        :is="injections.components.ObjectListItem"
        :key="item.id"
        :class="cssClass"
        :item-class="itemClass"
        :indent="indent"
        :skeleton="skeleton"
        :value="injections.helper.user.userBusinessObjectFor(item)"
        :item-link="itemLink"
        :selectable="selectable"
        :selected="selected"
        @click="toggleElement ? toggleElement(item) : {}"
      />
    </template>
  </component>
</template>
