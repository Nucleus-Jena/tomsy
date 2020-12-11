export default {
  methods: {
    userLinkFor (user) {
      return { name: 'user', params: { userId: user.id } }
    },
    userFullnameFor (user) {
      return `${user.firstname} ${user.lastname}`
    },
    userInitialsFor (user) {
      return `${user.firstname.charAt(0)}${user.lastname.charAt(0)}`
    },
    userAvatarImageUrlFor (user) {
      return user.avatarUrl
    },
    userBusinessObjectFor (user) {
      return {
        id: user.id,
        title: this.userFullnameFor(user),
        subtitleElements: [user.email],
        private: false,
        avatar: {
          text: this.userInitialsFor(user),
          image: this.userAvatarImageUrlFor(user)
        },
        type: 'User',
        href: ''
      }
    }
  },
  computed: {
    userFullname () {
      return this.userFullnameFor(this.user)
    },
    userInitials () {
      return this.userInitialsFor(this.user)
    },
    userAvatarImageUrl () {
      return this.userAvatarImageUrlFor(this.user)
    }
  }
}
