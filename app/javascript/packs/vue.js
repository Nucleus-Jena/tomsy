/* eslint no-console: 0 */

import Vue from 'vue'
import router from 'router'
import i18n from 'i18n'
import vuetify from 'plugins/vuetify'
import 'plugins/action-cable'
import config from 'helpers/config'
import apiEndpoints from 'api/endpoints'
import SiteHeader from 'components/site-header'
import SignInPage from 'pages/sign-in'

document.addEventListener('DOMContentLoaded', () => {
  (() => new Vue({
    el: '#vue-app',
    i18n,
    vuetify,
    apiEndpoints,
    config,
    router,
    components: { SiteHeader, SignInPage }
  }))()
})
