import { mount } from '@vue/test-utils'

import Vue from 'vue'
import Vuetify from 'vuetify'

import BreadcrumbsComponent from 'components/breadcrumbs'
Vue.use(Vuetify)

describe('Component', () => {
  test('is a Vue instance', () => {
    const wrapper = mount(BreadcrumbsComponent, {
      propsData: {
        items: ['bread', 'crumbs'] // BreadcrumbsComponent expects an array of strings
      }
    })
    expect(!!wrapper.vm).toBeTruthy()
  })
})
