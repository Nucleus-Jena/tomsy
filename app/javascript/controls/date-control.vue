<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Controlable from 'mixins/controlable'
import { formatDate } from 'helpers/date'

export default {
  name: 'DatePickerControl',
  mixins: [Requestable, Cacheable, Controlable],
  props: {
    ...requestablePropFactory().props,
    value: {
      type: String,
      default: undefined
    },
    sidebar: Boolean
  },
  data () {
    return {
      menuOpen: false
    }
  },
  computed: {
    localizedDateValue () {
      if (this.cacheValue) {
        return formatDate(new Date(this.cacheValue))
      } else {
        return ''
      }
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
  <v-menu
    ref="menu"
    v-model="menuOpen"
    :close-on-content-click="false"
    :return-value.sync="cacheValue"
    min-width="290px"
    offset-y
    transition="scale-transition"
    @update:return-value="controlOnChange"
  >
    <template #activator="{ on }">
      <v-input
        v-if="sidebar"
        class="custom-input-control custom-input-control--sidebar pl-4 pr-2 mt-2"
        :label="label"
        :error-messages="controlErrorMessages"
        :error-count="Number.MAX_VALUE"
      >
        <div class="custom-input-control__content mb-2">
          {{ localizedDateValue }}
        </div>
        <v-progress-linear
          v-if="controlLoading"
          absolute
          bottom
          height="2"
          indeterminate
        />
        <template #append>
          <v-btn
            v-if="hasErrors"
            :disabled="controlDisabled"
            color="error"
            small
            text
            @click.stop="controlOnChange"
          >
            {{ $t('general.buttons.retry') }}
          </v-btn>
          <v-btn
            v-else
            :disabled="controlDisabled"
            color="primary"
            small
            text
            v-on="on"
          >
            {{ $t('general.buttons.change') }}
          </v-btn>
        </template>
      </v-input>

      <v-text-field
        v-else
        :value="localizedDateValue"
        :label="label"
        :error-messages="controlErrorMessages"
        :error-count="Number.MAX_VALUE"
        :loading="controlLoading"
        readonly
        v-on="on"
      />
    </template>

    <v-date-picker
      v-model="cacheValue"
      no-title
      scrollable
    >
      <v-spacer />
      <v-btn
        color="error"
        text
        @click="$refs.menu.save(null)"
      >
        Löschen
      </v-btn>
      <v-btn
        :disabled="!cachedValueChanged"
        color="primary"
        depressed
        @click="$refs.menu.save(cacheValue)"
      >
        Speichern
      </v-btn>
    </v-date-picker>
  </v-menu>
</template>
