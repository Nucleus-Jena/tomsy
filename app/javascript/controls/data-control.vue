<script>
import TextControl from 'controls/text-control'
import TextareaControl from 'controls/textarea-control'
import BoolControl from 'controls/bool-control'
import DateControl from 'controls/date-control'
import CheckboxGroupControl from 'controls/checkbox-group-control'

export default {
  name: 'DataControl',
  props: {
    type: {
      type: String,
      required: true
    }
  },
  methods: {
    componentFromType (type) {
      switch (type) {
        case 'string': return TextControl
        case 'text': return TextareaControl
        case 'boolean': return BoolControl
        case 'date': return DateControl
        case 'datetime': return DateControl
        case 'enum': return CheckboxGroupControl
        default: return undefined
      }
    }
  }
}
</script>

<template functional>
  <component
    :is="$options.methods.componentFromType(props.type)"
    v-if="$options.methods.componentFromType(props.type) !== undefined"
    v-bind="data.attrs"
    v-on="listeners"
  />
  <v-alert
    v-else
    dense
    text
    type="error"
  >
    Der Datentyp "{{ props.type }}" wird nicht unterstützt
  </v-alert>
</template>
