<script>
import Menucardable from 'mixins/menucardable'

export default {
  name: 'MenuCardControl',
  mixins: [Menucardable],
  props: {
    loading: Boolean
  },
  methods: {
    onMenuCardOpened: function () {
      this.$emit('menu-card-opened')
    },
    onMenuCardClosed: function () {
      this.$emit('menu-card-closed')
    }
  }
}
</script>
<template>
  <v-menu
    v-model="internalVisible"
    :attach="attachElement"
    :close-on-click="closeOnClick && !loading"
    :close-on-content-click="closeOnContentClick"
    :nudge-bottom="nudgeBottom"
    min-width="100%"
    :absolute="absolute"
    transition="slide-y-transition"
    z-index="3"
    @update:return-value="onMenuReturnValue"
  >
    <template
      v-if="$scopedSlots.activator"
      #activator="{ on }"
    >
      <slot
        name="activator"
        :on="on"
      />
    </template>

    <v-card :loading="loading">
      <slot
        name="content"
        :instance="this"
      />
    </v-card>
  </v-menu>
</template>
