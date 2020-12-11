<script>
import { Bold, HardBreak, History, Italic, Strike, TiptapVuetify, Underline } from 'tiptap-vuetify'
import CustomMention from 'lib/tiptap-extensions/custom-mention'
import Request from 'api/request'
import User from 'mixins/models/user'
import ObjectListItem from 'list-items/object-list-item'
import debounce from 'lodash/debounce'
import AmbitionListItem from '../list-items/ambition-list-item'
import ProcessListItem from '../list-items/process-list-item'
import TaskListItem from '../list-items/task-list-item'

export default {
  name: 'EditorControl',
  components: { TiptapVuetify, ObjectListItem, AmbitionListItem, ProcessListItem, TaskListItem },
  mixins: [User],
  props: {
    value: { type: String, default: undefined },
    placeholder: { type: String, default: '' },
    loading: Boolean,
    disabled: Boolean,
    errors: { type: String, default: undefined },
    label: { type: String, default: '' },
    inline: Boolean,
    extensions: {
      type: Array,
      default: function () {
        return [
          HardBreak,
          Bold,
          Italic,
          Underline,
          Strike,
          History
        ]
      }
    }
  },
  data () {
    return {
      nativeExtensions: [
        new CustomMention({
          items: () => [],
          // is called when a suggestion starts
          onEnter: ({ matcherChar, query, range, command, virtualNode }) => {
            this.onSuggestion(true, matcherChar, query, range, command, virtualNode)
          },
          // is called when a suggestion has changed
          onChange: debounce(({ matcherChar, query, range, command, virtualNode }) => {
            this.onSuggestion(false, matcherChar, query, range, command, virtualNode)
          }, 500),
          // is called when a suggestion is cancelled
          onExit: () => {
            // reset all saved values
            this.query = null
            this.queryResult.type = null
            this.queryResult.objects = []
            this.suggestionRange = null
          },
          // is called on every keyDown event while a suggestion is active
          onKeyDown: ({ event }) => {
            return this.processEditorKeyDownEvent(event)
          }
        })
      ],
      userQueryRequest: new Request(),
      menuNudgeBottom: 0,
      menuWidth: 0,
      editor: null,
      queryLoading: false,
      query: null,
      suggestionRange: null,
      queryResult: {
        type: null,
        objects: []
      },
      insertMention: () => {
      },
      focused: false,
      selectedListItemIndex: 0
    }
  },
  computed: {
    hasResults () {
      return this.queryResult.objects.length
    },
    showSuggestions () {
      return this.queryLoading || this.query || this.hasResults
    }
  },
  methods: {
    typeForMatcherChar (matcherChar) {
      switch (matcherChar) {
        case '@': return 'user'
        case '!': return 'ambition'
        case '%': return 'process'
        case '#': return 'task'
      }
    },
    endpointForType (type) {
      switch (type) {
        case 'user': return this.$apiEndpoints.users.list()
        case 'ambition': return this.$apiEndpoints.ambitions.list()
        case 'process': return this.$apiEndpoints.processes.list()
        case 'task': return this.$apiEndpoints.tasks.list()
      }
    },
    onSuggestion (isOnEnter, matcherChar, query, range, command, virtualNode) {
      const rectEditor = this.$refs.tiptapEditor.$el.getBoundingClientRect()

      if (isOnEnter) this.menuWidth = rectEditor.width - 50

      const rectVN = virtualNode.getBoundingClientRect()
      this.menuNudgeBottom = rectVN.top + rectVN.height - rectEditor.top + 8
      this.queryLoading = true
      this.selectedListItemIndex = 0

      const objectType = this.typeForMatcherChar(matcherChar)
      this.userQueryRequest.get(this.endpointForType(objectType), {
        query: query
      }, true)
        .then((data) => {
          this.query = query
          this.queryResult.type = objectType
          this.queryResult.objects = data
          this.suggestionRange = range
          this.queryLoading = false
          // we save the command for inserting a selected mention
          // this allows us to call it inside of our custom popup
          // via keyboard navigation and on click
          if (isOnEnter) this.insertMention = command
        })
        .catch((error) => {
          this.queryLoading = false
          console.log('get data error:')
          console.log(error)
        })
    },
    valueChanged (value, info) {
      const json = info.getJSON().content

      if (Array.isArray(json) && json.length === 1 && !Object.prototype.hasOwnProperty.call(json[0], 'content')) {
        value = null
      }

      this.$emit('input', value)
    },
    onTipTapInit ({ editor }) {
      this.editor = editor
    },
    processEditorKeyDownEvent (event) {
      switch (event.keyCode) {
        case 38: // up
          this.selectedListItemIndex = (this.selectedListItemIndex > 0) ? this.selectedListItemIndex - 1 : this.queryResult.objects.length - 1
          break
        case 40: // down
          this.selectedListItemIndex = (this.selectedListItemIndex < this.queryResult.objects.length - 1) ? this.selectedListItemIndex + 1 : 0
          break
        case 9: // tab
        case 13: // enter
          this.selectObject(this.queryResult.objects[this.selectedListItemIndex], this.queryResult.type)
          break
        case 27: // esc
          this.$refs.suggestionMenu.onKeyDown(event)
          break
        default:
          return false
      }

      return true
    },
    // we have to replace our suggestion text with a mention
    // so it's important to pass also the position of your suggestion text
    selectObject (object, type) {
      this.insertMention({
        range: this.suggestionRange,
        attrs: {
          mId: object.id,
          mType: type,
          mNoAccess: false,
          mDeleted: false,
          mLabel: object.mentionLabel
        }
      })
      this.editor.focus()
    }
  }
}
</script>
<template>
  <div
    class="editor-control__wrapper"
    :class="{ 'editor-control--inline': inline, 'editor-control--is-focused': focused }"
  >
    <v-menu
      ref="suggestionMenu"
      content-class="mention-suggestions-menu"
      :value="showSuggestions"
      :nudge-bottom="menuNudgeBottom"
      nudge-right="25"
      :min-width="menuWidth"
      :max-width="menuWidth"
      transition="slide-y-transition"
    >
      <template #activator="{}">
        <tiptap-vuetify
          ref="tiptapEditor"
          :value="value"
          :extensions="extensions"
          :native-extensions="nativeExtensions"
          :disabled="disabled"
          :placeholder="placeholder"
          :card-props="{ loading: loading, flat: inline }"
          :class="{ 'primary--text': focused}"
          @input="valueChanged"
          @init="onTipTapInit"
          @focus="focused = true"
          @blur="focused = false"
        />
        <label
          v-if="label"
          class="v-label v-label--active theme--light d-block mb-1 editor-control__label"
          :class="{ 'primary--text': focused }"
        >{{ label }}</label>
      </template>
      <v-list
        class="py-0 u-scroll-y"
        max-height="400"
      >
        <v-list-item v-if="queryLoading">
          <v-list-item-content class="text-center">
            <v-progress-circular
              color="primary"
              indeterminate
            />
          </v-list-item-content>
        </v-list-item>
        <v-list-item-group
          v-else-if="hasResults"
          v-model="selectedListItemIndex"
          mandatory
        >
          <template v-for="object in queryResult.objects">
            <object-list-item
              v-if="queryResult.type === 'user'"
              :key="`list-item-${object.id}`"
              :value="userBusinessObjectFor(object)"
              indent
              @click="selectObject(object, queryResult.type)"
            />
            <ambition-list-item
              v-else-if="queryResult.type === 'ambition'"
              :key="`list-item-${object.id}`"
              :value="object"
              indent
              :dense="false"
              @click="selectObject(object, queryResult.type)"
            />
            <process-list-item
              v-else-if="queryResult.type === 'process'"
              :key="`list-item-${object.id}`"
              :value="object"
              indent
              :dense="false"
              @click="selectObject(object, queryResult.type)"
            />
            <task-list-item
              v-else-if="queryResult.type === 'task'"
              :key="`list-item-${object.id}`"
              :value="object"
              indent
              :dense="false"
              @click="selectObject(object, queryResult.type)"
            />
            <v-divider :key="`list-divider-${object.id}`" />
          </template>
        </v-list-item-group>
        <v-list-item v-else>
          <v-list-item-content class="text-center">
            Keine Ergebnisse
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-menu>

    <div class="text-caption secondary--text text--lighten-4 mt-2">
      {{ $t('general.editorHelpText') }}
    </div>
    <div
      v-if="errors"
      class="v-messages theme--light error--text"
      role="alert"
    >
      <div class="v-messages__wrapper">
        <div class="v-messages__message message-transition-enter-to">
          {{ errors }}
        </div>
      </div>
    </div>
  </div>
</template>
<style lang="scss">
    @import "~vuetify/src/styles/settings/_index";
    @import "app/assets/stylesheets/vue/object-links";

    .editor-control {
      &__wrapper {
        position: relative;
      }

      &__label {
        position: absolute;
        top: 26px;
        font-size: 12px !important;
      }

      &--inline {
        .tiptap-vuetify-editor:before {
          border-color: rgba(0,0,0,.42);
          border-style: solid;
          border-width: thin 0 0;
          bottom: -1px;
          content: "";
          left: 0;
          position: absolute;
          transition: .3s cubic-bezier(.25,.8,.5,1);
          width: 100%;
        }
        .tiptap-vuetify-editor:after {
          border-color: currentcolor;
          border-style: solid;
          border-width: thin 0;
          transform: scaleX(0);
          bottom: -1px;
          content: "";
          left: 0;
          position: absolute;
          transition: .3s cubic-bezier(.25,.8,.5,1);
          width: 100%;
        }
        &.editor-control--is-focused {
          .tiptap-vuetify-editor:after {
            transform: scaleX(1);
          }
        }

        .tiptap-vuetify-editor__toolbar > header {
          justify-content: flex-end;

          &.grey.lighten-4 {
            background-color: transparent !important;
          }
        }

        .tiptap-vuetify-editor__content {
          padding-left: 0;
          padding-right: 0;

          .ProseMirror {
            margin: 0 !important;

            p {
              margin-top: 0.5em !important;
              margin-bottom: 0 !important;

              &:first-child {
                margin-top: 0 !important;
              }
            }
          }
        }
      }
    }

    .mention-suggestion {
        color: map-get($blue, 'darken-2');
    }

</style>
