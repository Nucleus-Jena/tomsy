<script>
import UserInfo from './user-info'
import AvatarComponent from 'components/avatar-component'
import User from 'mixins/models/user'
import Ability from 'mixins/models/ability'
import trim from 'lodash/trim'

export default {
  name: 'SiteHeader',
  components: { UserInfo, AvatarComponent },
  mixins: [User, Ability],
  data () {
    return {
      drawer: false,
      query: ''
    }
  },
  methods: {
    search () {
      this.query = trim(this.query)
      if (this.query !== '') {
        this.$router.push({ name: 'search', params: { query: this.query } })
      }
    }
  }
}
</script>
<template>
  <div>
    <v-app-bar
      app
      dark
      clipped-left
      clipped-right
      color="blue darken-3"
    >
      <v-app-bar-nav-icon
        class="hidden-md-and-up mr-2"
        @click="drawer = true"
      />
      <v-toolbar-title class="hidden-sm-and-down pl-0 mr-2 flex-grow-2 flex-shrink-1">
        <v-btn
          :to="{name: 'home'}"
          text
          class="site-header-home-link pa-0 text-none text-h5 d-inline"
        >
          <v-img
            class="mr-2"
            :src="require('images/ms-icon-310x310.png')"
            :max-height="28"
            :max-width="28"
            contain
          />
          <div class="text-truncate">
            {{ $t('general.appName') }}
          </div>
        </v-btn>
      </v-toolbar-title>

      <template v-if="$config.current_user">
        <v-spacer class="hidden-sm-and-down" />
        <v-toolbar-items class="mr-8 hidden-sm-and-down">
          <v-btn
            :to="{name: 'ambitions'}"
            text
          >
            Ziele
          </v-btn>
          <v-btn
            :to="{name: 'processes'}"
            text
          >
            Maßnahmen
          </v-btn>
          <v-btn
            :to="{name: 'tasks'}"
            text
          >
            Aufgaben
          </v-btn>
          <v-btn
            :to="{name: 'dossiers'}"
            text
          >
            Dossiers
          </v-btn>
        </v-toolbar-items>
        <div class="d-flex flex-grow-1 mr-8">
          <v-text-field
            id="fulltext-search"
            v-model="query"
            flat
            solo-inverted
            hide-details
            prepend-inner-icon="mdi-magnify"
            label="Suchen"
            @keydown.enter="search"
          />
        </div>

        <user-info />

        <v-menu
          left
          bottom
          offset-y
        >
          <template #activator="{ on }">
            <v-btn
              id="user-menu"
              class="mr-1"
              icon
              v-on="on"
            >
              <avatar-component
                :text="userInitialsFor($config.current_user)"
                :image="userAvatarImageUrlFor($config.current_user)"
                white
              />
            </v-btn>
          </template>
          <v-list id="user-menu-list">
            <v-list-item>
              <v-list-item-content>
                <v-list-item-title>{{ userFullnameFor($config.current_user) }}</v-list-item-title>
                <v-list-item-subtitle>{{ $config.current_user.email }}</v-list-item-subtitle>
              </v-list-item-content>
            </v-list-item>
            <template v-if="$ability.can('access', $config.current_user.abilities.camunda)">
              <v-divider />
              <v-subheader>Camunda Workflow Engine</v-subheader>
              <v-list-item
                href="http://localhost:8080/camunda/app/cockpit/default/"
                target="_blank"
              >
                <v-list-item-content>
                  <v-list-item-title>Cockpit</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item
                href="http://localhost:8080/camunda/app/tasklist/default/"
                target="_blank"
              >
                <v-list-item-content>
                  <v-list-item-title>Tasklist</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item
                href="http://localhost:8080/camunda/app/admin/default/"
                target="_blank"
              >
                <v-list-item-content>
                  <v-list-item-title>Admin</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <template v-if="$ability.can('access', $config.current_user.abilities.rails_admin)">
              <v-divider />
              <v-list-item
                href="/admin/"
                target="_blank"
              >
                <v-list-item-content>
                  <v-list-item-title>Rails Admin</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-divider />
            <v-list-item href="/users/sign_out">
              <v-list-item-content>
                <v-list-item-title>Abmelden</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-menu>
      </template>
    </v-app-bar>
    <v-navigation-drawer
      v-model="drawer"
      absolute
      temporary
    >
      <v-list nav>
        <v-subheader class="d-flex text-h5 mx-n2 mt-n2 px-4 py-2 primary">
          <v-img
            class="mr-2"
            :src="require('images/ms-icon-310x310.png')"
            :max-height="28"
            :max-width="28"
            contain
          />
          <div class="white--text text-truncate">
            {{ $t('general.appName') }}
          </div>
        </v-subheader>

        <v-list-item
          :to="{name: 'home'}"
          exact
        >
          <v-list-item-content>
            <v-list-item-title>Home</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
        <v-list-item :to="{name: 'ambitions'}">
          <v-list-item-content>
            <v-list-item-title>Ziele</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
        <v-list-item :to="{name: 'processes'}">
          <v-list-item-content>
            <v-list-item-title>Maßnahmen</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
        <v-list-item :to="{name: 'tasks'}">
          <v-list-item-content>
            <v-list-item-title>Aufgaben</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
        <v-list-item :to="{name: 'dossiers'}">
          <v-list-item-content>
            <v-list-item-title>Dossiers</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
  </div>
</template>
<style>
    .site-header-home-link::before {
        opacity: 0 !important;
    }
</style>
