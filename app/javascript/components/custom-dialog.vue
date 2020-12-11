<script>
export default {
  name: 'CustomDialog',
  props: {
    title: { type: String, required: true },
    text: { type: String, default: undefined },
    cancelBtnText: {
      type: String,
      default: 'Abbrechen'
    },
    cancelBtnColor: {
      type: String,
      default: 'secondary'
    },
    okBtnText: {
      type: String,
      default: 'OK'
    },
    okBtnColor: {
      type: String,
      default: 'primary'
    },
    okBtnDisabled: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      dialogOpen: false
    }
  },
  watch: {
    dialogOpen (open) {
      this.onInputUpdated(open)
    }
  },
  methods: {
    okClicked () {
      this.dialogOpen = false
      this.$emit('click-ok')
    },
    onInputUpdated (open) {
      if (open) this.$emit('open')
    }
  }
}
</script>
<template>
  <v-dialog
    v-model="dialogOpen"
    persistent
    max-width="960"
    @input="onInputUpdated"
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
    <v-card>
      <v-card-title v-if="title">
        {{ title }}
      </v-card-title>
      <v-card-text v-if="$scopedSlots.default">
        <slot />
      </v-card-text>
      <v-card-text v-else-if="text">
        {{ text }}
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn
          :color="cancelBtnColor"
          text
          @click="dialogOpen = false"
        >
          {{ cancelBtnText }}
        </v-btn>
        <v-btn
          :color="okBtnColor"
          :disabled="okBtnDisabled"
          depressed
          @click="okClicked"
        >
          {{ okBtnText }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
