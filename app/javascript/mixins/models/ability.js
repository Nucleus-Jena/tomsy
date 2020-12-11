export default {
  computed: {
    $ability () {
      return {
        can (action, subject) {
          if ((typeof subject !== 'undefined') && (typeof subject.abilities !== 'undefined')) {
            return (subject.abilities[action] === true) || (subject.abilities.manage === true)
          }

          return false
        },
        cannot (action, subject) {
          return !this.can(action, subject)
        }
      }
    }
  }
}
