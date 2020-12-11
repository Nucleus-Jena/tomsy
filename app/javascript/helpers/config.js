import Vue from 'vue'

Vue.mixin({
  beforeCreate () {
    const options = this.$options
    if (options.config) { this.$config = options.config } else if (options.parent && options.parent.$config) { this.$config = options.parent.$config }
  }
})

const configJson = JSON.parse(document.getElementById('vue-config').innerHTML)

export default {
  current_user: configJson.current_user,
  isCurrentUser: function (user) {
    return configJson.current_user && user && user.id === configJson.current_user.id
  }
}
