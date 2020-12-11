const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vueLoader = require('./loaders/vue')
const vuetifyLoader = require('./loaders/vue')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vuetifyLoader)
environment.loaders.prepend('vue', vueLoader)

// see https://stackoverflow.com/questions/53582944/how-to-properly-install-vuetify-for-rails
const resolver = {
  resolve: {
    alias: {
      vue$: 'vue/dist/vue.esm.js'
    }
  }
}
environment.config.merge(resolver)

module.exports = environment
