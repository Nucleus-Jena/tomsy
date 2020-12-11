<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import EditorControl from 'controls/editor-control'
import EditorContent from 'components/editor-content'
import { Blockquote, CodeBlock, HardBreak, Heading, OrderedList, BulletList, ListItem, TodoItem, TodoList, Bold, Italic, Link, Strike, Underline, History } from 'tiptap-vuetify'

export default {
  name: 'TitleDescriptionControl',
  components: { EditorControl, EditorContent },
  mixins: [Requestable, Cacheable],
  props: {
    ...requestablePropFactory().props,
    title: {
      type: String,
      required: true
    },
    description: {
      type: String,
      default: ''
    },
    editableTitle: {
      type: Boolean,
      default: true
    },
    disabled: Boolean
  },
  data () {
    return {
      editMode: false
    }
  },
  computed: {
    titleChanged () {
      return this.cacheValue.title !== this.title
    },
    descriptionChanged () {
      return this.cacheValue.description !== this.description
    },
    cachedValueChanged () {
      return this.titleChanged || this.descriptionChanged
    },
    changedValue () {
      const res = {}
      if (this.titleChanged) res.title = this.cacheValue.title
      if (this.descriptionChanged) res.description = this.cacheValue.description

      return res
    },
    editorExtensions () {
      return [
        HardBreak,
        Bold,
        Italic,
        Underline,
        Strike,
        Link,
        [Heading, {
          options: {
            levels: [1, 2, 3]
          }
        }],
        Blockquote,
        CodeBlock,
        OrderedList,
        BulletList,
        ListItem,
        TodoItem,
        TodoList,
        History]
    }
  },
  watch: {
    description: {
      handler () {
        this.createCacheValue()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    createCacheValue: function () {
      this.cacheValue = {
        title: this.title,
        description: this.description
      }
    },
    onEdit: function () {
      this.editMode = true
    },
    onCancel: function () {
      this.editMode = false
      this.createCacheValue()
      this.resetRequestable()
    },
    onRequestSuccess: function (data) {
      this.editMode = false

      if (this.titleChanged) this.$emit('update:title', this.cacheValue.title)
      if (this.descriptionChanged) this.$emit('update:description', this.cacheValue.description)

      if (data) {
        this.$emit('request-success-data', data)
      }
    }
  }
}
</script>
<template>
  <div v-if="!editMode">
    <div class="d-flex mb-2">
      <h1 class="text-h4 font-weight-light">
        {{ title }}
      </h1>

      <v-btn
        :disabled="disabled"
        class="ml-auto"
        color="primary"
        icon
        @click="onEdit"
      >
        <v-icon>mdi-square-edit-outline</v-icon>
      </v-btn>
    </div>
    <div class="secondary--text">
      <editor-content :template="description" />
    </div>
  </div>
  <v-card
    v-else
    :loading="requestableLoading"
  >
    <v-card-text class="pb-0">
      <v-text-field
        v-if="editableTitle"
        v-model="cacheValue.title"
        :disabled="requestableLoading"
        :error-messages="validationErrorMessageFor('title')"
        autofocus
        class="mb-4"
        error-count="5"
        :label="$t('general.title')"
      />
      <h1
        v-else
        class="mb-4 text-h4 font-weight-light"
      >
        {{ title }}
      </h1>

      <editor-control
        v-model="cacheValue.description"
        :extensions="editorExtensions"
        :disabled="requestableLoading"
        inline
        :label="$t('general.description')"
        :errors="validationErrorMessageFor('description')"
      />
    </v-card-text>

    <v-card-actions class="px-4">
      <div
        v-if="hasErrors"
        class="error--text"
      >
        {{ baseErrorMessage }}
      </div>
      <v-spacer />
      <v-btn
        :disabled="requestableLoading"
        color="secondary"
        text
        @click="onCancel"
      >
        {{ $t("general.buttons.cancel") }}
      </v-btn>

      <v-btn
        color="primary"
        :disabled="!cachedValueChanged || requestableLoading"
        depressed
        @click="cachedValueChanged && request(requestParameter, null, cacheValue)"
      >
        {{ $t("general.buttons.save") }}
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
<style lang="scss">
  blockquote {
    border-left: .25em solid #dfe2e5;
    color: #6a737d;
    padding-left: 1em;
    margin: 20px 0!important;
    font-weight: 300;
  }

  li.tiptap-vuetify-todo-item-view {
    div.v-input.mt-3 {
      margin-top: 0 !important;
      margin-right: 4px !important;
      padding-top: 0 !important;
    }

    .todo-content p {
      line-height: 24px;
    }
  }

  ul[data-type="todo_list"] {
    list-style-type: none;
    padding: 0 !important;
    margin: 0;

    li {
      display: flex;

      span.todo-checkbox {
        margin-right: 0.5em;
        font-size: 24px;

        &:before {
          display: inline-block;
          font: normal normal normal 24px/1 "Material Design Icons";
          font-size: inherit;
          text-rendering: auto;
          line-height: inherit;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
          content: "\F131";
        }
      }

      &[data-done="true"] span.todo-checkbox:before {
        content: "\F132";
        color: #1976d2 !important;
        caret-color: #1976d2 !important;
      }

      .todo-content p {
        line-height: 36px;
        margin-bottom: 0;
      }
    }
  }
</style>
