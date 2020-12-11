<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Controlable from 'mixins/controlable'

export default {
  name: 'SwitchControl',
  mixins: [Requestable, Cacheable, Controlable],
  props: {
    ...requestablePropFactory().props,
    value: Boolean,
    sidebar: Boolean
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
  <v-switch
    v-model="cacheValue"
    :class="[{'px-4': sidebar}, {'pb-2': hasErrors}]"
    :label="label"
    :loading="controlLoading"
    :disabled="controlDisabled"
    :error-messages="controlErrorMessages"
    :error-count="Number.MAX_VALUE"
    @change="controlOnChange"
  />
</template>
