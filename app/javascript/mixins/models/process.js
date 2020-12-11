import { stateColors } from 'helpers/definitions'
import includes from 'lodash/includes'
import find from 'lodash/find'

const PROCESS_STATE_RUNNING = 'running'
const PROCESS_STATE_COMPLETED = 'completed'
const PROCESS_STATE_CANCELED = 'canceled'
const PROCESS_STATES = [PROCESS_STATE_RUNNING, PROCESS_STATE_COMPLETED, PROCESS_STATE_CANCELED]

export default {
  methods: {
    processLinkFor (process) {
      return this.processNoAccessFor(process) ? null : { name: 'process', params: { processId: process.id } }
    },
    processIdentifierFor (process) {
      return `%${process.id}`
    },
    processGetTaskWithIdFor (process, taskId) {
      if (process) {
        return find(process.tasks, { id: taskId })
      } else {
        return null
      }
    },
    processIsRunningFor (process) {
      return process.state === PROCESS_STATE_RUNNING
    },
    processNoAccessFor (process) {
      return process.noAccess === true
    }
  },
  computed: {
    processBreadcrumbs () {
      return [
        { text: 'Maßnahmen', to: { name: 'processes' } },
        { text: this.process.definition.name, to: { name: 'processes', query: { process_definitions: [this.process.definition.id] } } },
        { text: `%${this.process.id}` }
      ]
    },
    processStateText () {
      if (includes(PROCESS_STATES, this.process.state)) {
        return this.$t('process.state.' + this.process.state)
      } else {
        throw new Error('stateText: Unsupported process state: ' + this.process.state)
      }
    },
    processStateColor () {
      switch (this.process.state) {
        case PROCESS_STATE_RUNNING:
          return stateColors.started
        case PROCESS_STATE_COMPLETED:
          return stateColors.completed
        case PROCESS_STATE_CANCELED:
          return stateColors.canceled
        default:
          throw new Error('stateColor: Unsupported process state: ' + this.process.state)
      }
    },
    processStateUpdatedAtDate () {
      return this.process.stateUpdatedAt ? new Date(this.process.stateUpdatedAt) : null
    },
    processIdentifier () {
      return this.processIdentifierFor(this.process)
    },
    processIsRunning () {
      return this.processIsRunningFor(this.process)
    },
    processNoAccess () {
      return this.processNoAccessFor(this.process)
    }
  }
}
