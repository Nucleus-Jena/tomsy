<script>
import PageContent from '../page-content'
import SidebarLeft from '../sidebar-left'
import SidebarRight from '../sidebar-right'
import PageTitle from 'mixins/page-title'

export default {
  name: 'SignInPage',
  components: {
    PageContent,
    SidebarLeft,
    SidebarRight
  },
  mixins: [PageTitle],
  props: {
    messages: {
      type: String,
      default: '[]'
    }
  },
  data () {
    return {
      email: '',
      password: '',
      showPassword: false,
      rules: {
        required: value => !!value || 'Erforderlich'
      }
    }
  },
  computed: {
    authenticityToken () {
      return document.querySelector('[name="csrf-token"]') || { content: 'no-csrf-token' }
    },
    messagesArray () {
      return JSON.parse(this.messages)
    },
    pageTitleParts () {
      return ['Anmelden']
    }
  },
  methods: {
    alertType (messageType) {
      switch (messageType) {
        case 'notice':
          return 'info'
        case 'alert':
        case 'error':
          return 'error'
        default:
          return null
      }
    }
  }
}
</script>
<template>
  <div class="page-signin">
    <sidebar-left floating />

    <page-content>
      <v-row class="d-flex justify-center">
        <v-col
          cols="12"
          sm="6"
        >
          <h4 class="mb-6">
            Anmelden
          </h4>

          <template v-for="(message, index) in messagesArray">
            <v-alert
              v-if="alertType(message.type)"
              :key="index"
              :type="alertType(message.type)"
            >
              {{ message.text }}
            </v-alert>
          </template>
          <v-form
            id="sign-in"
            action="/users/sign_in"
            accept-charset="UTF-8"
            method="post"
          >
            <input
              type="hidden"
              name="authenticity_token"
              :value="authenticityToken.content"
            >
            <v-text-field
              v-model="email"
              name="user[email]"
              label="E-Mail"
              prepend-icon="mdi-account-circle"
              :rules="[rules.required]"
              required
            />
            <v-text-field
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              name="user[password]"
              label="Passwort"
              :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
              prepend-icon="mdi-lock"
              required
              :rules="[rules.required]"
              @click:append="showPassword = !showPassword"
            />
            <input
              type="hidden"
              name="user[remember_me]"
              value="0"
            >
            <v-checkbox
              name="user[remember_me]"
              value="1"
              label="Angemeldet bleiben"
            />

            <v-btn
              type="submit"
              :disabled="email === '' || password === ''"
            >
              Anmelden
            </v-btn>
          </v-form>
        </v-col>
      </v-row>
    </page-content>

    <sidebar-right floating />
  </div>
</template>
