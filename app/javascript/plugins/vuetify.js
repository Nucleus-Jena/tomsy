import Vue from 'vue'
import Vuetify from 'vuetify'

import { TiptapVuetifyPlugin } from 'tiptap-vuetify'
import 'tiptap-vuetify/dist/main.css'

import de from 'vuetify/es5/locale/de'
import 'vuetify/dist/vuetify.min.css'
import 'typeface-roboto'
import '@mdi/font/css/materialdesignicons.min.css'

const vuetify = new Vuetify({
  lang: {
    locales: { de },
    current: 'de'
  }
})

Vue.use(Vuetify)
Vue.use(TiptapVuetifyPlugin, {
  vuetify,
  iconsGroup: 'mdi'
})

export default vuetify
