import { stateColors } from 'helpers/definitions'
import process from 'mixins/models/process'
import reduce from 'lodash/reduce'

export default {
  methods: {
    ambitionLinkFor (ambition) {
      return this.ambitionNoAccessFor(ambition) ? null : { name: 'ambition', params: { ambitionId: ambition.id } }
    },
    ambitionStateTextFor (ambition) {
      if (ambition.closed) {
        return this.$t('ambition.state.closed')
      } else {
        return this.$t('ambition.state.open')
      }
    },
    ambitionRunningProcessCountTextFor (ambition) {
      return this.$tc('ambition.openProcessesCount', ambition.processOpenCount)
    },
    ambitionSubtitleElementsFor (ambition) {
      const elements = [`!${ambition.id}`, this.ambitionStateTextFor(ambition)]
      if (!ambition.closed) {
        elements.push(this.ambitionRunningProcessCountTextFor(ambition))
      }

      return elements
    },
    ambitionBusinessObjectFor (ambition) {
      return {
        id: ambition.id,
        title: ambition.title,
        subtitleElements: this.ambitionSubtitleElementsFor(ambition),
        private: ambition.private,
        avatar: null,
        type: 'Ziel',
        href: ''
      }
    },
    ambitionNoAccessFor (ambition) {
      return ambition.noAccess === true
    }
  },
  computed: {
    ambitionBreadcrumbs () {
      return [
        { text: 'Ziele', to: { name: 'ambitions' } },
        { text: `!${this.ambition.id}` }
      ]
    },
    ambitionStateText () {
      return this.ambitionStateTextFor(this.ambition)
    },
    ambitionStateColor () {
      if (this.ambition.closed) {
        return stateColors.completed
      } else {
        return stateColors.started
      }
    },
    ambitionStateUpdatedAtDate () {
      return new Date(this.ambition.stateUpdatedAt)
    },
    ambitionIdentifier () {
      return `!${this.ambition.id}`
    },
    ambitionRunningProcessCountText () {
      return this.ambitionRunningProcessCountTextFor(this.ambition)
    },
    ambitionRunningProcessWithAccessCount () {
      return reduce(this.ambition.processes, function (result, value) {
        return result + ((!process.methods.processNoAccessFor(value) && process.methods.processIsRunningFor(value)) ? 1 : 0)
      }, 0)
    },
    hasNoAccessProcesses () {
      return reduce(this.ambition.processes, function (result, value) {
        return result || process.methods.processNoAccessFor(value)
      }, false)
    }
  }
}

// This could be an option if we need to namespace computed properties to use them with multiple objects
/*
export default function(refName = "ambition", namespace = "") {
    return {
        computed: {
            [`${refName}Breadcrumbs`]() {
                return [`Ziel !${this[refName].id}`];
            },
            breadcrumbs() {
                return [`Ziel !${this[refName].id}`];
            }
        }
    }
} */
