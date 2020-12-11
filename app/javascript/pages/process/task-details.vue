<script>
import Breadcrumbs from 'components/breadcrumbs'
import PageDetailHeader from 'components/page-detail-header'
import TitleDescriptionControl from 'controls/title-description-control'
import ActivityHub from 'components/activity-hub'

import DataControl from 'controls/data-control'
import DossierControl from '../../controls/dossiers/dossier-control'
import DocumentsControl from 'controls/documents-control'
import SupportInformationBox from 'components/support-information-box'

import Task from 'mixins/models/task'
import Ability from 'mixins/models/ability'
import Request from 'api/request'

export default {
  name: 'TaskDetails',
  components: {
    Breadcrumbs,
    PageDetailHeader,
    TitleDescriptionControl,
    ActivityHub,
    DataControl,
    DossierControl,
    DocumentsControl,
    SupportInformationBox
  },
  mixins: [Ability, Task],
  props: {
    task: { type: Object, required: true },
    process: { type: Object, required: true }
  },
  data () {
    return {
      activities: null,
      data: null
    }
  },
  watch: {
    $props: {
      handler () {
        this.activities = null
        if (this.task) {
          new Request().get(this.$apiEndpoints.tasks.getData(this.task.id))
            .then((data) => {
              this.data = data
            })
            .catch((error) => {
              console.log('get data error:')
              console.log(error)
            })

          new Request().get(this.$apiEndpoints.tasks.activities(this.task.id))
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
    processUpdated (process) {
      this.$emit('update:process', process)
    }
  }
}
</script>
<template>
  <div>
    <breadcrumbs
      class="mb-2"
      :items="taskBreadcrumbs"
    />

    <page-detail-header
      class="mb-7"
      :state-text="taskStateText"
      :state-updated-at="taskStateUpdatedAtDate"
      :state-color="taskStateColor.background"
      :comment-count="task.commentsCount"
      @comment-count-click="$refs.activityhub.scrollToAndShowComments()"
    >
      <template #actions="{actionRequest, loading}">
        <v-btn
          v-if="taskIsStarted"
          color="primary"
          text
          :disabled="loading || $ability.cannot('complete', task)"
          @click="actionRequest($apiEndpoints.tasks.complete(task.id), processUpdated)"
        >
          Aufgabe abschließen
        </v-btn>
      </template>
    </page-detail-header>

    <title-description-control
      :title="task.definition.name"
      :description.sync="task.description"
      :request-parameter="{method: 'patch', url: $apiEndpoints.tasks.update(task.id)}"
      :disabled="$ability.cannot('update', task)"
      :editable-title="false"
      class="mb-8"
      @request-success-data="processUpdated"
    />

    <template v-if="data && data.items">
      <template v-for="dataItem in data.items">
        <documents-control
          v-if="dataItem.type === 'has_many_files'"
          :key="dataItem.name"
          v-model="dataItem.value"
          :label="dataItem.label"
          :task-id="task.id"
          :data-entity-field="dataItem.name"
          @request-success-data="processUpdated"
        />
        <dossier-control
          v-else-if="dataItem.type === 'has_one_dossier' || dataItem.type === 'has_many_dossiers'"
          :key="dataItem.name"
          v-model="dataItem.value"
          :label="dataItem.label"
          :update-request-parameter="{method: 'patch', url: $apiEndpoints.tasks.updateData(task.id), mapping: dataItem.name}"
          :list-request-parameter="{method: 'get', url: $apiEndpoints.dossiers.list(), params: {definition: dataItem.parameter.type}}"
          :single="dataItem.type === 'has_one_dossier'"
          @request-success-data="processUpdated"
        />
        <support-information-box
          v-else-if="dataItem.type === 'info'"
          :key="dataItem.name"
          :data="dataItem"
          class="mb-2"
        />
        <data-control
          v-else
          :key="dataItem.name"
          v-model="dataItem.value"
          :type="dataItem.type"
          :label="dataItem.label"
          :request-parameter="{method: 'patch', url: $apiEndpoints.tasks.updateData(task.id), mapping: dataItem.name}"
          :items="dataItem.type === 'enum' ? dataItem.parameter.values : undefined"
          @request-success-data="processUpdated"
        />
      </template>
    </template>

    <activity-hub
      ref="activityhub"
      :activities="activities"
      :request-parameter="{method: 'post', url: $apiEndpoints.tasks.comment(task.id), mapping: 'message'}"
      class="mt-12"
      :disabled="$ability.cannot('update', task)"
      @new-comment-success="processUpdated"
    />
  </div>
</template>
