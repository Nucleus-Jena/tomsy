<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Controlable from 'mixins/controlable'

export default {
  name: 'TextControl',
  mixins: [Requestable, Cacheable, Controlable],
  props: {
    ...requestablePropFactory().props,
    value: {
      type: String,
      default: undefined
    }
  },
  methods: {
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
  <v-text-field
    v-model="cacheValue"
    :label="label"
    :loading="controlLoading"
    :disabled="controlDisabled"
    :error-count="Number.MAX_VALUE"
    :error-messages="controlErrorMessages"
    :hint="hint"
    :persistent-hint="persistentHint"
    @change="controlOnChange"
  />
</template>
