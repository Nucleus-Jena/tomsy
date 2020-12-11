<script>
import AvatarComponent from 'components/avatar-component'
import { icon, url, subtitleElements } from 'helpers/document'

export default {
  name: 'DocumentListItem',
  components: { AvatarComponent },
  props: {
    value: {
      type: Object,
      required: true
    },
    actions: {
      type: Boolean,
      default: true
    },
    linkable: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    icon () {
      return icon(this.value)
    },
    subtitleElements () {
      return subtitleElements(this.value)
    }
  },
  methods: {
    openItem: function () {
      window.open(url(this.value), '_blank')
    }
  }
}
</script>
<template>
  <v-list-item v-on="linkable ? { click: openItem } : {}">
    <avatar-component
      :icon="icon"
      class="mr-2"
      list
    />

    <v-list-item-content>
      <v-list-item-title>{{ value.title }}</v-list-item-title>
      <v-list-item-subtitle class="custom-meta-list">
        <span
          v-for="item in subtitleElements"
          :key="item"
        >
          {{ item }}
        </span>
      </v-list-item-subtitle>
    </v-list-item-content>

    <v-list-item-action
      v-if="actions"
      class="px-4"
    >
      <v-menu
        bottom
        left
      >
        <template #activator="{ on }">
          <v-btn
            icon
            v-on="on"
          >
            <v-icon color="grey lighten-1">
              mdi-dots-vertical
            </v-icon>
          </v-btn>
        </template>
        <v-list>
          <v-list-item @click="$emit('edit')">
            Bearbeiten
          </v-list-item>
          <v-list-item @click="$emit('delete')">
            Löschen
          </v-list-item>
        </v-list>
      </v-menu>
    </v-list-item-action>
  </v-list-item>
</template>
