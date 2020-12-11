<script>
import VRuntimeTemplate from 'v-runtime-template'
import Mention from 'components/mention'

export default {
  name: 'EditorContent',
  components: {
    VRuntimeTemplate,
    // eslint-disable-next-line vue/no-unused-components
    Mention
  },
  props: {
    template: {
      type: String,
      default: ''
    },
    parent: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    wrappedTemplate () {
      return `<div>${this.template}</div>`
    }
  }
}
</script>
<template>
  <v-runtime-template
    v-if="template"
    :template="wrappedTemplate"
    :parent="parent"
    class="editor-content"
  />
</template>
<style>
  .editor-content p:last-child {
    margin-bottom: 0;
  }
</style>
