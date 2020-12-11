import { stateColors } from 'helpers/definitions'
import includes from 'lodash/includes'
import { distanceDate } from 'helpers/date'

const TASK_STATE_CREATED = 'created'
const TASK_STATE_STARTED = 'started'
const TASK_STATE_COMPLETED = 'completed'
const TASK_STATE_DELETED = 'deleted'
const TASK_STATES = [TASK_STATE_CREATED, TASK_STATE_STARTED, TASK_STATE_COMPLETED, TASK_STATE_DELETED]

export default {
  methods: {
    taskLinkFor (task) {
      return this.taskNoAccessFor(task) ? null : { name: 'task', params: { processId: task.process.id, taskId: task.id } }
    },
    taskNoAccessFor (task) {
      return task.noAccess === true
    }
  },
  computed: {
    taskBreadcrumbs () {
      return [
        { text: 'Maßnahmen', to: { name: 'processes' } },
        { text: this.process.definition.name, to: { name: 'processes', query: { process_definitions: [this.process.definition.id] } } },
        { text: `%${this.process.id} • ${this.process.title}`, to: { name: 'process', params: { processId: this.process.id } } },
        { text: 'Aufgaben' },
        { text: `#${this.task.id}` }
      ]
    },
    taskStateText () {
      if (includes(TASK_STATES, this.task.state)) {
        return this.$t('task.state.' + this.task.state)
      } else {
        throw new Error('stateText: Unsupported task state: ' + this.task.state)
      }
    },
    taskStateColor () {
      switch (this.task.state) {
        case TASK_STATE_CREATED:
          return stateColors.created
        case TASK_STATE_STARTED:
          return stateColors.started
        case TASK_STATE_COMPLETED:
          return stateColors.completed
        case TASK_STATE_DELETED:
          return stateColors.canceled
        default:
          throw new Error('stateColor: Unsupported task state: ' + this.task.state)
      }
    },
    taskIsCreated () {
      return this.task.state === TASK_STATE_CREATED
    },
    taskIsStarted () {
      return this.task.state === TASK_STATE_STARTED
    },
    taskStateUpdatedAtDate () {
      return this.task.stateUpdatedAt ? new Date(this.task.stateUpdatedAt) : null
    },
    taskDueAtDate () {
      return this.task.dueAt ? new Date(this.task.dueAt) : null
    },
    taskDueDistanceText () {
      return this.$t('task.dueDistance', { distance: distanceDate(this.taskDueAtDate) })
    },
    taskIdentifier () {
      return `#${this.task.id}`
    }
  }
}
