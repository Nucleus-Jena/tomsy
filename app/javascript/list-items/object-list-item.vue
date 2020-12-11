<script>
import ListItemTemplate from './list-item-template'
import AvatarComponent from 'components/avatar-component'

export default {
  name: 'ObjectListItem',
  components: { ListItemTemplate, AvatarComponent },
  props: {
    ...ListItemTemplate.props,
    value: {
      type: Object,
      required: true
    },
    showType: Boolean,
    actionLink: Boolean
  }
}
</script>
<template>
  <list-item-template
    skeleton-type="list-item-avatar-two-line"
    v-bind="$props"
    @click="$emit('click', $event)"
  >
    <avatar-component
      v-if="value.avatar"
      :text="value.avatar.text"
      :image="value.avatar.image"
      :icon="value.avatar.icon"
      class="mr-2"
      list
    />

    <v-list-item-content>
      <v-list-item-title class="d-flex align-baseline">
        <v-icon
          v-if="value.private"
          class="mr-1"
          color="black"
          size="16"
        >
          mdi-lock-outline
        </v-icon>
        <span>{{ value.title }}</span>
      </v-list-item-title>
      <v-list-item-subtitle class="custom-meta-list">
        <span
          v-for="(element, index) in value.subtitleElements"
          :key="index"
          class="d-flex"
        >
          {{ element }}
        </span>
      </v-list-item-subtitle>
    </v-list-item-content>

    <v-list-item-action v-if="(showType && value.type) || (actionLink && value.href)">
      <v-list-item-action-text v-if="showType && value.type">
        {{ value.type }}
      </v-list-item-action-text>
      <v-btn
        v-if="actionLink && value.href"
        :href="value.href"
        color="primary"
        icon
        target="_blank"
        x-small
      >
        <v-icon>mdi-open-in-new</v-icon>
      </v-btn>
    </v-list-item-action>
  </list-item-template>
</template>
