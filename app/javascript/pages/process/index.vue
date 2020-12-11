<script>
import PageContent from '../page-content'
import SidebarLeft from '../sidebar-left'
import SidebarRight from '../sidebar-right'
import ProcessDetails from './process-details'
import ProcessSidebarLeft from './process-sidebar-left'
import ProcessSidebarRight from './process-sidebar-right'
import TaskDetails from './task-details'
import TaskSidebarRight from './task-sidebar-right'
import Requestable from 'mixins/requestable'
import Request from 'api/request'
import Process from 'mixins/models/process'
import Task from 'mixins/models/task'
import PageTitle from 'mixins/page-title'

export default {
  name: 'ProcessPage',
  components: {
    TaskSidebarRight,
    PageContent,
    SidebarLeft,
    SidebarRight,
    ProcessSidebarLeft,
    ProcessSidebarRight,
    ProcessDetails,
    TaskDetails
  },
  mixins: [Requestable, PageTitle, Process, Task],
  props: {
    processId: {
      type: Number,
      default: undefined
    },
    taskId: {
      type: Number,
      default: undefined
    }
  },
  data () {
    return {
      process: null
    }
  },
  computed: {
    pageTitleParts () {
      if (this.taskId) {
        return [...(this.process && this.processGetTaskWithIdFor(this.process, this.taskId) ? [this.processGetTaskWithIdFor(this.process, this.taskId).referenceLabel] : []), 'Aufgaben']
      } else {
        return [...(this.process ? [this.process.referenceLabel] : []), 'Maßnahmen']
      }
    }
  },
  watch: {
    processId: {
      handler () {
        this.process = null
        this.fetchData()
      },
      deep: true,
      immediate: true
    },
    taskId: {
      handler () {
        this.setPageTitle()
      }
    }
  },
  methods: {
    fetchData () {
      if (this.hasErrors) this.resetRequestable()
      this.request({
        method: Request.GET,
        url: (this.processId === undefined && this.taskId !== undefined) ? this.$apiEndpoints.tasks.get(this.taskId) : this.$apiEndpoints.processes.get(this.processId)
      },
      null, null, true)
    },
    onRequestSuccess: function (data) {
      if (this.processId === undefined) {
        this.$router.replace(this.taskLinkFor(this.processGetTaskWithIdFor(data, this.taskId)))
      } else {
        this.process = data
        this.setPageTitle()
      }
    }
  }
}
</script>
<template>
  <div :class="taskId ? 'page-task' : 'page-process'">
    <sidebar-left>
      <process-sidebar-left
        v-if="process"
        :process="process"
      />
    </sidebar-left>

    <page-content
      :error="error"
      @reload="fetchData"
    >
      <task-details
        v-if="process && processGetTaskWithIdFor(process, taskId)"
        :task="processGetTaskWithIdFor(process, taskId)"
        :process.sync="process"
      />
      <process-details
        v-else-if="process"
        v-model="process"
      />
    </page-content>

    <sidebar-right>
      <task-sidebar-right
        v-if="processGetTaskWithIdFor(process, taskId)"
        :task="processGetTaskWithIdFor(process, taskId)"
        @update-process="process = $event"
      />
      <process-sidebar-right
        v-else-if="process"
        :process="process"
      />
    </sidebar-right>
  </div>
</template>
