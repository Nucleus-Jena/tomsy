<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Controlable from 'mixins/controlable'
import cloneDeep from 'lodash/cloneDeep'
import isArray from 'lodash/isArray'

export default {
  name: 'CheckboxGroupControl',
  mixins: [Requestable, Cacheable, Controlable],
  props: {
    ...requestablePropFactory().props,
    value: {
      type: Array,
      default: function () { return [] }
    },
    items: {
      type: Array,
      default: function () { return [] }
    }
  },
  data () {
    return {
      currentItemId: null
    }
  },
  methods: {
    createCacheValue: function () {
      if (isArray(this.value)) {
        this.cacheValue = cloneDeep(this.value)
      } else {
        this.cacheValue = []
      }
    },
    onClicked: function (id) {
      this.currentItemId = id
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
    class="custom-input-control custom-checkbox-control"
    :label="label"
    :error-messages="controlErrorMessages"
    :error-count="Number.MAX_VALUE"
  >
    <v-list
      class="py-0"
      width="100%"
    >
      <v-list-item-group
        v-model="cacheValue"
        multiple
        @change="controlOnChange"
      >
        <v-list-item
          v-for="item in items"
          :key="item.id"
          :value="item.id"
          :disabled="controlDisabled || controlHasErrors"
          class="px-0"
          @click="onClicked(item.id)"
        >
          <template v-slot:default="{ active }">
            <v-list-item-action class="mr-2">
              <v-progress-circular
                v-if="controlLoading && currentItemId === item.id"
                color="primary"
                indeterminate
                size="20"
                width="2"
              />
              <v-icon
                v-else
                :color="active ? 'primary' : undefined"
                :disabled="controlDisabled || controlHasErrors"
              >
                {{ active ? "$checkboxOn" : "$checkboxOff" }}
              </v-icon>
            </v-list-item-action>
            <v-list-item-content>
              <v-list-item-title :class="[{'text--disabled': controlDisabled || controlHasErrors}]">
                {{ item.label }}
              </v-list-item-title>
            </v-list-item-content>
          </template>
        </v-list-item>
      </v-list-item-group>
    </v-list>

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
