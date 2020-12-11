<script>
export default {
  name: 'ErrorView',
  props: {
    error: {
      type: Object,
      default: null
    }
  }
}
</script>
<template>
  <v-alert
    :value="error !== null"
    prominent
    type="error"
    transition="scale-transition"
  >
    <v-row
      v-if="error"
      align="center"
    >
      <v-col class="grow">
        <span
          v-if="error.code() === 403"
          v-html="$t('error.request.code.403')"
        />
        <span
          v-else-if="error.code() === 404"
          v-html="$t('error.request.code.404')"
        />
        <span
          v-else-if="error.code() === 410"
          v-html="$t('error.request.code.410')"
        />
        <template v-else>
          <span v-html="$t('error.request.code.default')" />
          <div
            v-if="error"
            class="body-2 mt-2"
          >
            {{ error.errorMessage }}
          </div>
        </template>
      </v-col>
      <v-col
        v-if="error.code() !== 403 && error.code() !== 404 && error.code() !== 410"
        class="shrink"
      >
        <v-btn @click="$emit('reload')">
          Neuladen
        </v-btn>
      </v-col>
    </v-row>
  </v-alert>
</template>
