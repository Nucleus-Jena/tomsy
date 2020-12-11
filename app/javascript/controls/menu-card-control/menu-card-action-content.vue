<script>
export default {
  name: 'MenuCardActionContent',
  props: {
    title: {
      type: String,
      default: undefined
    },
    text: {
      type: String,
      default: undefined
    },
    primaryBtnText: {
      type: String,
      default: 'OK'
    },
    primaryBtnDisabled: Boolean,
    secondaryBtnText: {
      type: String,
      default: 'Abbrechen'
    },
    loading: Boolean,
    baseErrorMessage: {
      type: String,
      default: undefined
    }
  },
  methods: {
    primaryBtnClicked () {
      this.$emit('click-primary-btn')
    },
    secondaryBtnClicked () {
      this.$emit('click-secondary-btn')
    }
  }
}
</script>
<template>
  <div>
    <v-card-title v-if="title">
      {{ title }}
    </v-card-title>
    <v-card-text v-if="text || $scopedSlots.default">
      {{ text }}
      <slot />
    </v-card-text>

    <v-card-actions class="px-4">
      <div
        v-if="baseErrorMessage"
        class="error--text"
      >
        {{ baseErrorMessage }}
      </div>
      <v-spacer />
      <v-btn
        :disabled="loading"
        color="secondary"
        text
        @click="secondaryBtnClicked"
      >
        {{ secondaryBtnText }}
      </v-btn>
      <v-btn
        :disabled="primaryBtnDisabled || loading"
        color="primary"
        depressed
        @click="primaryBtnClicked"
      >
        {{ primaryBtnText }}
      </v-btn>
    </v-card-actions>
  </div>
</template>
