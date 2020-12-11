import Task from './task'
import Process from './process'
import Ambition from './ambition'

export default {
  methods: {
    eventObjectTypeFromEventTypeFor (type) {
      switch (type) {
        case 'assigned':
        case 'unassigned':
        case 'addedContributor':
        case 'removedContributor':
          return 'user'
        case 'addedSuccessorProcess':
        case 'addedProcess':
        case 'removedProcess':
        case 'completedProcess':
          return 'process'
        default:
          return null
      }
    },
    eventValueNoAccessFor (type, value) {
      switch (type) {
        case 'task':
          return Task.methods.taskNoAccessFor(value)
        case 'process':
          return Process.methods.processNoAccessFor(value)
        case 'ambition':
          return Ambition.methods.ambitionNoAccessFor(value)
        default:
          return false
      }
    },
    eventValueElementsFor (type, value, showReference) {
      const result = []

      switch (type) {
        case 'task':
          result.push({ type: 'text', text: this.$t('event.object.task') })
          if (showReference) {
            result.push({ type: 'reference', data: value[0] })
            result.push({ type: 'text', text: this.$t('event.object.ofProcess') })
            result.push({ type: 'reference', data: value[1] })
          }
          break
        case 'process':
          result.push({ type: 'text', text: this.$t('event.object.process') })
          if (showReference) {
            result.push({ type: 'reference', data: value })
          }
          break
        case 'ambition':
          result.push({ type: 'text', text: this.$t('event.object.ambition') })
          if (showReference) {
            result.push({ type: 'reference', data: value })
          }
          break
        case 'user':
          result.push({ type: 'text', text: this.$t('event.object.user') })
          if (showReference) {
            result.push({ type: 'reference', data: value })
          }
          break
        default:
          result.push({ type: 'value', text: value })
      }

      return result
    },
    eventIconClassFor (event) {
      switch (event.type) {
        case 'created':
          return 'mdi-plus'
        case 'started':
          return 'mdi-play-outline'
        case 'completed':
          return 'mdi-check'
        case 'canceled':
          return 'mdi-close'
        case 'deleted':
          return 'mdi-trash-can-outline'
        case 'reopened':
          return 'mdi-undo'
        case 'assigned':
          return 'mdi-account-outline'
        case 'unassigned':
          return 'mdi-account-outline'
        case 'addedContributor':
          return 'mdi-account-multiple-outline'
        case 'removedContributor':
          return 'mdi-account-multiple-outline'
        case 'addedSuccessorProcess':
          return 'mdi-location-exit'
        case 'addedProcess':
          return 'mdi-bookmark-plus-outline'
        case 'removedProcess':
          return 'mdi-bookmark-minus-outline'
        case 'completedProcess':
          return 'mdi-bookmark-check-outline'
        case 'changedDueDate':
          return 'mdi-calendar-blank-outline'
        case 'changedTitle':
          return 'mdi-playlist-edit'
        case 'changedVisibility':
          return 'mdi-lock-open-outline'
        case 'changedSummary':
          return 'mdi-playlist-edit'
        case 'changed':
          return 'mdi-database-edit'
        default:
          return false
      }
    },
    eventPathPrefixFor (event) {
      return 'event.' + (event.user ? 'withSubject' : 'withoutSubject') + '.' + event.type
    },
    eventMainPathFor (event, showReference) {
      const subkey = (showReference ? 'referenced' : 'normal')

      if (this.$te(this.eventPathPrefixFor(event) + '.' + subkey)) {
        return this.eventPathPrefixFor(event) + '.' + subkey
      }

      return this.eventPathPrefixFor(event)
    },
    eventNewValuePathFor (event) {
      return this.eventPathPrefixFor(event) + '.newValuePart'
    },
    eventOldValuePathFor (event) {
      return this.eventPathPrefixFor(event) + '.oldValuePart'
    },
    eventDeleteValuePathFor (event) {
      return this.eventPathPrefixFor(event) + '.deleteValuePart'
    },
    eventObjectTypePathFor (type) {
      return 'event.object.' + type
    },
    eventMentionedPathFor (event) {
      return this.eventPathPrefixFor(event) + '.mentioned'
    }
  },
  computed: {
    eventIconClass () {
      return this.eventIconClassFor(this.event)
    },
    eventMainPath () {
      return this.eventMainPathFor(this.event, this.showReference)
    },
    eventNewValuePath () {
      return this.eventNewValuePathFor(this.event)
    },
    eventOldValuePath () {
      return this.eventOldValuePathFor(this.event)
    },
    eventDeleteValuePath () {
      return this.eventDeleteValuePathFor(this.event)
    },
    eventObjectTypePath () {
      return this.eventObjectTypePathFor(this.event.objectType)
    },
    eventMentionedPath () {
      return this.eventMentionedPathFor(this.event)
    },
    eventObjectValueElements () {
      return this.eventValueElementsFor(this.event.objectType, this.event.object, this.showReference)
    },
    eventOldValueElements () {
      return this.eventValueElementsFor(
        this.eventObjectTypeFromEventTypeFor(this.event.type),
        this.event.oldValue,
        true
      )
    },
    eventNewValueElements () {
      return this.eventValueElementsFor(
        this.eventObjectTypeFromEventTypeFor(this.event.type),
        this.event.newValue,
        true
      )
    },
    eventObjectValueNoAccess () {
      return this.eventValueNoAccessFor(this.event.objectType, this.event.object)
    }
  }
}
