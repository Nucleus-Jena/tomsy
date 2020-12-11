<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Controlable from 'mixins/controlable'

export default {
  name: 'BoolControl',
  mixins: [Requestable, Cacheable, Controlable],
  props: {
    ...requestablePropFactory().props,
    value: {
      type: Boolean,
      default: undefined
    }
  },
  data () {
    return {
      trueClicked: false,
      falseClicked: false
    }
  },
  methods: {
    btnClicked: function (val) {
      this.trueClicked = val === true
      this.falseClicked = val === false

      this.cacheValue = val === this.cacheValue ? null : val
      this.controlOnChange()
    },
    onRequestSuccess (data) {
      this.$emit('input', this.cacheValue)

      if (data) {
        this.$emit('request-success-data', data)
      }
    }
  }
}
</script>

<template>
  <v-input
    class="custom-input-control"
    :label="label"
    :error-messages="controlErrorMessages"
    :error-count="Number.MAX_VALUE"
  >
    <v-btn-toggle
      :value="cacheValue"
      color="primary"
      dense
    >
      <v-btn
        :disabled="controlDisabled && falseClicked || controlHasErrors"
        :loading="controlLoading && trueClicked"
        :value="true"
        text
        @click="btnClicked(true)"
      >
        Ja
      </v-btn>

      <v-btn
        :disabled="controlDisabled && trueClicked || controlHasErrors"
        :loading="controlLoading && falseClicked"
        :value="false"
        text
        @click="btnClicked(false)"
      >
        Nein
      </v-btn>
    </v-btn-toggle>

    <template
      v-if="controlHasErrors"
      v-slot:append
    >
      <v-btn
        :disabled="controlDisabled"
        color="error"
        small
        text
        @click.stop="controlOnChange"
      >
        {{ $t('general.buttons.retry') }}
      </v-btn>
    </template>
  </v-input>
</template>
