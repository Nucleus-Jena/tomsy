<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Controlable from 'mixins/controlable'

export default {
  name: 'TextareaControl',
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
  <v-textarea
    v-model="cacheValue"
    :label="label"
    :loading="controlLoading"
    :disabled="controlDisabled"
    :error-count="Number.MAX_VALUE"
    :error-messages="controlErrorMessages"
    :hint="hint"
    :persistent-hint="persistentHint"
    auto-grow
    rows="1"
    @change="controlOnChange"
  />
</template>
