<script>
import Breadcrumbs from 'components/breadcrumbs'
import PageDetailHeader from 'components/page-detail-header'
import TitleDescriptionControl from 'controls/title-description-control'
import ActivityHub from 'components/activity-hub'
import ObjectsControl from 'controls/objects-control'
import ProcessListItem from 'list-items/process-list-item'
import CustomDialog from 'components/custom-dialog'
import Ability from 'mixins/models/ability'
import Ambition from 'mixins/models/ambition'
import Request from 'api/request'

export default {
  name: 'AmbitionDetails',
  components: {
    Breadcrumbs,
    PageDetailHeader,
    TitleDescriptionControl,
    ActivityHub,
    ObjectsControl,
    ProcessListItem,
    CustomDialog
  },
  mixins: [Ability, Ambition],
  inject: {
    helper: {
      default: {
        Request
      }
    }
  },
  model: {
    prop: 'ambition',
    event: 'change'
  },
  props: {
    ambition: { type: Object, required: true }
  },
  data () {
    return {
      menuOpen: false,
      activities: null
    }
  },
  computed: {
    closeDialogTitle () {
      if (this.ambitionRunningProcessWithAccessCount > 0) {
        return this.$t('ambition.closeDialog.title.openProcesses')
      } else if (this.hasNoAccessProcesses) {
        return this.$t('ambition.closeDialog.title.noAccessProcesses')
      } else {
        return this.$t('ambition.closeDialog.title.standard')
      }
    },
    closeDialogText () {
      if (this.ambitionRunningProcessWithAccessCount > 0) {
        return this.$t('ambition.closeDialog.text.openProcesses')
      } else if (this.hasNoAccessProcesses) {
        return this.$t('ambition.closeDialog.text.noAccessProcesses')
      } else {
        return this.$t('ambition.closeDialog.text.standard')
      }
    }
  },
  watch: {
    $props: {
      handler () {
        this.activities = null
        if (this.ambition) {
          new Request().get(this.$apiEndpoints.ambitions.activities(this.ambition.id))
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
    onAmbitionUpdated (ambition) {
      this.$emit('change', ambition)
    },
    onAmbitionDeleted () {
      this.$router.replace({ name: 'ambitions' })
    }
  }
}
</script>
<template>
  <div>
    <breadcrumbs
      class="mb-2"
      :items="ambitionBreadcrumbs"
    />

    <page-detail-header
      class="mb-7"
      :state-text="ambitionStateText"
      :state-updated-at="ambitionStateUpdatedAtDate"
      :state-color="ambitionStateColor.background"
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
              v-if="ambition.closed"
              :disabled="$ability.cannot('toggle_completeness', ambition)"
              @click="actionRequest($apiEndpoints.ambitions.reopen(ambition.id), onAmbitionUpdated)"
            >
              <v-list-item-title>{{ $t('ambition.detailActions.reopen') }}</v-list-item-title>
            </v-list-item>

            <v-list-item
              v-if="!ambition.closed"
              :disabled="$ability.cannot('toggle_completeness', ambition)"
              @click.stop="$refs.ambitionCloseDialog.dialogOpen = true"
            >
              <v-list-item-title>{{ $t('ambition.detailActions.close') }}</v-list-item-title>
            </v-list-item>

            <custom-dialog
              ref="ambitionCloseDialog"
              :title="closeDialogTitle"
              :text="closeDialogText"
              :ok-btn-text="$t('ambition.closeDialog.buttonOk')"
              @click-ok="actionRequest($apiEndpoints.ambitions.close(ambition.id), onAmbitionUpdated)"
              @open="menuOpen = false"
            />

            <v-list-item
              :disabled="$ability.cannot('destroy', ambition)"
              @click="$refs.deleteDialog.dialogOpen = true"
            >
              <v-list-item-title>{{ $t('ambition.detailActions.delete') }}</v-list-item-title>
            </v-list-item>

            <custom-dialog
              ref="deleteDialog"
              :title="$t('ambition.deleteDialog.title')"
              :text="$t('ambition.deleteDialog.text')"
              :ok-btn-text="$t('ambition.deleteDialog.buttonOk')"
              ok-btn-color="error"
              @click-ok="actionRequest($apiEndpoints.ambitions.destroy(ambition.id), onAmbitionDeleted, helper.Request.DELETE)"
              @open="menuOpen = false"
            />
          </v-list>
        </v-menu>
      </template>
    </page-detail-header>

    <title-description-control
      :title.sync="ambition.title"
      :description.sync="ambition.description"
      :request-parameter="{method: 'patch', url: $apiEndpoints.ambitions.update(ambition.id)}"
      :disabled="ambition.closed || $ability.cannot('update', ambition)"
      class="mb-8"
      @request-success-data="onAmbitionUpdated"
    />

    <objects-control
      v-model="ambition.processes"
      :update-request-parameter="{method: 'patch', url: $apiEndpoints.ambitions.updateProcesses(ambition.id), mapping: 'processes'}"
      :list-request-parameter="{method: 'get', url: $apiEndpoints.processes.list()}"
      :disabled="ambition.closed"
      :label="`Zu erledigende Maßnahmen (${ambitionRunningProcessWithAccessCount} von ${ambition.processes.length} offen)`"
      indent
      outlined
    >
      <template #list-item="{item, indent, cssClass, itemLink, skeleton, selectable, selected, toggleElement}">
        <process-list-item
          :key="item.id"
          :class="cssClass"
          :indent="indent"
          :item-link="itemLink"
          :selectable="selectable"
          :selected="selected"
          :skeleton="skeleton"
          :value="item"
          :to="{name: 'process', params: { processId: item.id }}"
          @click="toggleElement ? toggleElement(item) : {}"
        />
      </template>

      <template #empty>
        <v-card-text>Notwendige Maßnahmen zur Erreichung des Ziels hinzufügen</v-card-text>
      </template>
    </objects-control>

    <activity-hub
      ref="activityhub"
      :activities="activities"
      :request-parameter="{method: 'post', url: $apiEndpoints.ambitions.comment(ambition.id), mapping: 'message'}"
      class="mt-12"
      :disabled="$ability.cannot('update', ambition)"
      @new-comment-success="onAmbitionUpdated"
    />
  </div>
</template>
