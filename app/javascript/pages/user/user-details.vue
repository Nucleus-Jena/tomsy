<script>
import AvatarComponent from 'components/avatar-component'
import User from 'mixins/models/user'

export default {
  name: 'UserDetails',
  components: { AvatarComponent },
  mixins: [User],
  props: {
    user: {
      type: Object,
      required: true
    }
  }
}
</script>
<template>
  <div>
    <avatar-component
      :text="userInitials"
      :image="userAvatarImageUrl"
      class="mt-2 mb-2"
    />
    <h1 class="text-h4 font-weight-light">
      {{ userFullname }}
    </h1>
    <div>{{ user.email }}</div>
  </div>
</template>
