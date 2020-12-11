import { Node } from 'tiptap'
import { replaceText } from 'tiptap-commands'
import { Suggestions as SuggestionsPlugin } from 'tiptap-extensions'
import Mention from 'components/mention'

export default class CustomMention extends Node {
  get name () {
    return 'custom_mention'
  }

  get defaultOptions () {
    return {
      matcherChars: ['@', '!', '%', '#'],
      suggestionClass: 'mention-suggestion'
    }
  }

  get schema () {
    return {
      attrs: {
        mId: {},
        mType: {},
        mNoAccess: false,
        mDeleted: false,
        mLabel: {}
      },
      group: 'inline',
      inline: true,
      selectable: false,
      atom: true,
      toDOM: node => [
        'mention',
        {
          'm-id': node.attrs.mId,
          'm-type': node.attrs.mType,
          ':noaccess': String(node.attrs.mNoAccess),
          ':deleted': String(node.attrs.mDeleted)
        },
        node.attrs.mLabel
      ],
      parseDOM: [
        {
          tag: 'mention[m-id][m-type]',
          getAttrs: dom => {
            const mId = dom.getAttribute('m-id')
            const mType = dom.getAttribute('m-type')
            const mNoAccess = dom.getAttribute(':noaccess') === 'true'
            const mDeleted = dom.getAttribute(':deleted') === 'true'
            const mLabel = dom.innerText
            return { mId, mType, mNoAccess, mDeleted, mLabel }
          }
        }
      ]
    }
  }

  commands ({ schema }) {
    return attrs => replaceText(null, schema.nodes[this.name], attrs)
  }

  get plugins () {
    return this.options.matcherChars.map(matcherChar => {
      return SuggestionsPlugin({
        command: ({ range, attrs, schema }) => replaceText(range, schema.nodes[this.name], attrs),
        appendText: ' ',
        matcher: {
          char: matcherChar,
          allowSpaces: false,
          startOfLine: false
        },
        items: this.options.items,
        onEnter: (data) => this.options.onEnter({ ...data, matcherChar: matcherChar }),
        onChange: (data) => this.options.onChange({ ...data, matcherChar: matcherChar }),
        onExit: (data) => this.options.onExit({ ...data, matcherChar: matcherChar }),
        onKeyDown: this.options.onKeyDown,
        onFilter: this.options.onFilter,
        suggestionClass: this.options.suggestionClass
      })
    })
  }

  get view () {
    return {
      props: ['node'],
      components: { Mention },
      computed: {
        mId () {
          return String(this.node.attrs.mId)
        },
        mType () {
          return this.node.attrs.mType
        },
        mNoAccess () {
          return this.node.attrs.mNoAccess
        },
        mDeleted () {
          return this.node.attrs.mDeleted
        },
        mLabel () {
          return this.node.attrs.mLabel
        }
      },
      template: '<mention :m-id="mId" :m-type="mType" :noaccess="mNoAccess" :deleted="mDeleted">{{ mLabel }}</mention>'
    }
  }
}
