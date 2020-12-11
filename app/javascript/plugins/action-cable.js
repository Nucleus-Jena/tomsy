import Vue from 'vue'
import ActionCableVue from 'actioncable-vue'

Vue.use(ActionCableVue, {
  debug: true,
  debugLevel: 'error',
  connectionUrl: document.head.querySelector("meta[name='action-cable-url']").content,
  connectImmediately: true
})
