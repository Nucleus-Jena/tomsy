<script>
import PageContent from '../page-content'
import ApiError from 'api/error/api-error'

export default {
  name: 'ErrorPage',
  components: {
    PageContent
  },
  computed: {
    error () {
      const error = new ApiError()
      error.errorCode = 404
      return error
    }
  }
}
</script>
<template>
  <page-content
    class="page-error"
    :error="error"
  />
</template>
