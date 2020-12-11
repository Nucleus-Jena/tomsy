<script>
import ProcessListItem from 'list-items/process-list-item'
import ProcessesCreateControl from './processes-create-control'
import cloneDeep from 'lodash/cloneDeep'
import isArray from 'lodash/isArray'

export default {
  name: 'ProcessesControl',
  components: { ProcessListItem, ProcessesCreateControl },
  props: {
    label: { type: String, required: true },
    icon: { type: String, default: undefined },
    value: { type: [Object, Array], default: undefined },
    addable: Boolean,
    ambitionId: { type: Number, default: undefined },
    predecessorProcessId: { type: Number, default: undefined },
    disabled: Boolean
  },
  data () {
    return {
      showCardMenu: false
    }
  },
  computed: {
    internalValue () {
      if (this.value) {
        return (isArray(this.value)) ? cloneDeep(this.value) : [cloneDeep(this.value)]
      } else {
        return []
      }
    }
  }
}
</script>
<template>
  <v-card
    ref="container"
    class="custom-control"
    outlined
  >
    <processes-create-control
      v-if="addable"
      v-model="showCardMenu"
      :ambition-id="ambitionId"
      :predecessor-process-id="predecessorProcessId"
      :attach="$refs.container"
      :nudge-bottom="52"
      close-on-click
    />

    <v-card-title class="pa-3 flex-nowrap">
      <v-icon
        v-if="icon"
        class="mr-1"
        size="28"
      >
        {{ icon }}
      </v-icon>
      <div class="mr-auto text-body-1 text--secondary text-truncate">
        {{ label }}
      </div>
      <v-btn
        v-if="addable"
        :disabled="disabled || showCardMenu"
        color="primary"
        small
        text
        @click.stop="showCardMenu = true"
      >
        Hinzufügen
      </v-btn>
    </v-card-title>

    <v-list
      :disabled="showCardMenu"
      class="py-0"
    >
      <template v-for="(item, index) in internalValue">
        <process-list-item
          :key="item.id"
          :class="[{'pt-2': index > 0}]"
          :value="item"
          :to="{ name: 'process', params: { processId: item.id } }"
          class="pb-2"
          indent
        />
        <v-divider
          v-if="index < internalValue.length - 1"
          :key="`list-divider-${item.id}`"
        />
      </template>
    </v-list>
  </v-card>
</template>
