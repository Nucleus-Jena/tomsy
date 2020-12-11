import Vue from 'vue'
import VueI18n from 'vue-i18n'
import generalDE from 'i18n/modules/general.de'
import errorDE from 'i18n/modules/error.de'
import eventDE from 'i18n/modules/event.de'
import notificationDE from 'i18n/modules/notification.de'
import ambitionDE from 'i18n/modules/ambition.de'
import processDE from 'i18n/modules/process.de'
import taskDE from 'i18n/modules/task.de'
import dossierDE from 'i18n/modules/dossier.de'

Vue.use(VueI18n)

const messages = {
  de: {
    general: generalDE,
    error: errorDE,
    event: eventDE,
    notification: notificationDE,
    ambition: ambitionDE,
    process: processDE,
    task: taskDE,
    dossier: dossierDE
  }
}

export default new VueI18n({
  locale: 'de',
  messages
})
