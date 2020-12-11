<script>
import Breadcrumbs from 'components/breadcrumbs'
import PageDetailHeader from 'components/page-detail-header'
import TitleDescriptionControl from 'controls/title-description-control'
import ProcessesControl from 'controls/processes-control'
import ActivityHub from 'components/activity-hub'
import Process from 'mixins/models/process'
import Ability from 'mixins/models/ability'
import CustomDialog from 'components/custom-dialog'
import Request from 'api/request'

export default {
  name: 'ProcessDetails',
  components: {
    Breadcrumbs,
    PageDetailHeader,
    TitleDescriptionControl,
    ProcessesControl,
    ActivityHub,
    CustomDialog
  },
  mixins: [Ability, Process],
  model: {
    prop: 'process',
    event: 'change'
  },
  props: {
    process: { type: Object, required: true }
  },
  data () {
    return {
      menuOpen: false,
      cancelInfo: '',
      successorProcesses: [],
      activities: null
    }
  },
  watch: {
    $props: {
      handler () {
        this.activities = null
        if (this.process) {
          new Request().get(this.$apiEndpoints.processes.activities(this.process.id))
            .then((data) => {
              this.activities = data
            })
            .catch((error) => {
              console.log('get data error:')
              console.log(error)
            })
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    openCancelDialog () {
      this.cancelInfo = ''
      this.$refs.processCancelDialog.dialogOpen = true
    },
    processUpdated (process) {
      this.$emit('change', process)
    }
  },
  inject: {
    helper: {
      default: {
        Request
      }
    }
  }
}
</script>
<template>
  <div>
    <breadcrumbs
      class="mb-2"
      :items="processBreadcrumbs"
    />

    <page-detail-header
      class="mb-7"
      :state-text="processStateText"
      :state-updated-at="processStateUpdatedAtDate"
      :state-color="processStateColor.background"
    >
      <template #actions="{actionRequest, loading}">
        <v-menu
          v-model="menuOpen"
          left
        >
          <template #activator="{ on }">
            <v-btn
              :disabled="loading"
              color="primary"
              icon
              v-on="on"
            >
              <v-icon>mdi-dots-vertical</v-icon>
            </v-btn>
          </template>

          <v-list>
            <v-list-item
              v-if="processIsRunning"
              :disabled="$ability.cannot('cancel', process)"
              @click.stop="openCancelDialog"
            >
              <v-list-item-title>Maßnahme abbrechen</v-list-item-title>
            </v-list-item>

            <custom-dialog
              ref="processCancelDialog"
              title="Maßnahme abbrechen"
              :ok-btn-disabled="cancelInfo === ''"
              @click-ok="actionRequest($apiEndpoints.processes.cancel(process.id), processUpdated, helper.Request.PATCH, null, { cancel_info: cancelInfo })"
              @open="menuOpen = false"
            >
              <v-text-field
                v-model="cancelInfo"
                label="Grund für den Abbruch"
              />
            </custom-dialog>

            <v-list-item @click="console.log('TODO: Implement Aufgabe starten')">
              <v-list-item-title>Neue Aufgabe starten</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </template>
    </page-detail-header>

    <title-description-control
      :title.sync="process.title"
      :description.sync="process.description"
      :request-parameter="{method: 'patch', url: $apiEndpoints.processes.update(process.id)}"
      :disabled="$ability.cannot('update', process)"
      class="mb-8"
      @request-success-data="processUpdated"
    />

    <processes-control
      v-if="process.predecessorProcess"
      :value="process.predecessorProcess"
      class="mb-8"
      icon="mdi-location-enter"
      label="Vorangegangene Maßnahme"
    />

    <processes-control
      :value="process.successorProcesses"
      :predecessor-process-id="process.id"
      :disabled="$ability.cannot('update', process)"
      addable
      icon="mdi-location-exit"
      label="Folgemaßnahmen"
      class="mb-8"
    />

    <activity-hub
      ref="activityhub"
      :activities="activities"
      :request-parameter="{method: 'post', url: $apiEndpoints.processes.comment(process.id), mapping: 'message'}"
      class="mt-12"
      :disabled="$ability.cannot('update', process)"
      @new-comment-success="processUpdated"
    />
  </div>
</template>
