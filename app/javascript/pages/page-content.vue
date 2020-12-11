<script>
import ErrorView from 'components/error-view'

export default {
  name: 'PageContent',
  components: { ErrorView },
  props: {
    error: {
      type: Object,
      default: null
    }
  },
  inject: {
    components: {
      default: { ErrorView }
    }
  }
}
</script>
<template functional>
  <v-main :class="[data.class, data.staticClass]">
    <v-container
      style="max-width: 960px;"
      class="pb-8"
    >
      <component
        :is="injections.components.ErrorView"
        :error="props.error"
        v-on="listeners.reload ? { reload: listeners.reload } : {}"
      />
      <slot />
    </v-container>
  </v-main>
</template>
