<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import ObjectListView from 'data-views/object-list-view'
import ObjectsSelectCardMenu from './objects-select-card-menu'
import isArray from 'lodash/isArray'
import cloneDeep from 'lodash/cloneDeep'
import findIndex from 'lodash/findIndex'
import forEach from 'lodash/forEach'
import map from 'lodash/map'

export default {
  name: 'ObjectsControl',
  components: { ObjectListView, ObjectsSelectCardMenu },
  mixins: [Requestable, Cacheable],
  model: {
    prop: 'value',
    event: 'change'
  },
  props: {
    ...requestablePropFactory('updateRequestParameter').props,
    ...requestablePropFactory('listRequestParameter').props,
    label: { type: String, required: true },
    icon: { type: String, default: undefined },
    value: { type: [Object, Array], default: undefined },
    queryMaxResults: {
      type: Number,
      default: 10
    },
    single: Boolean,
    disabled: Boolean,
    indent: Boolean,
    sidebar: Boolean,
    outlined: Boolean,
    divider: {
      type: Boolean,
      default: true
    }
  },
  data () {
    return {
      itemsSelected: [],
      menuOpen: false
    }
  },
  computed: {
    showValues () {
      if (this.requestableLoading || this.hasErrors) {
        const newValues = this.cacheValue.map((item) => {
          const itemCopy = cloneDeep(item)
          itemCopy.skeleton = (findIndex(this.itemsSelected, { id: item.id }) === -1)
          return itemCopy
        })

        if (!this.single || newValues.length === 0) {
          forEach(this.itemsSelected, (item) => {
            if ((findIndex(this.cacheValue, { id: item.id }) === -1)) {
              const itemCopy = cloneDeep(item)
              itemCopy.skeleton = true
              newValues.push(itemCopy)
            }
          })
        }
        return newValues
      } else {
        return this.cacheValue
      }
    }
  },
  methods: {
    createCacheValue () {
      if (this.value) {
        this.cacheValue = cloneDeep(this.value)
        if (!isArray(this.cacheValue)) {
          this.cacheValue = [this.cacheValue]
        }
      } else {
        this.cacheValue = []
      }
    },
    onSelectionChanged (selectedItems) {
      this.itemsSelected = selectedItems
      this.saveSelection()
    },
    saveSelection () {
      if (this.single) {
        this.request(this.updateRequestParameter, null, this.itemsSelected.length === 0 ? null : this.itemsSelected[0].id)
      } else {
        this.request(this.updateRequestParameter, null, map(this.itemsSelected, 'id'))
      }
    },
    onRequestSuccess (data) {
      if (this.single) {
        this.$emit('change', this.itemsSelected.length === 0 ? null : this.itemsSelected[0])
      } else {
        this.$emit('change', this.itemsSelected)
      }

      if (data) {
        this.$emit('request-success-data', data)
      }
    }
  }
}
</script>
<template>
  <v-input
    :class="{'custom-object-control--sidebar' : sidebar}"
    :error-messages="errorMessage"
    :loading="requestableLoading"
    class="custom-object-control"
  >
    <v-card
      ref="container"
      :flat="!outlined"
      :outlined="outlined"
    >
      <objects-select-card-menu
        v-model="menuOpen"
        :attach="$refs.container"
        :nudge-bottom="sidebar ? 36 : 52"
        :request-parameter="listRequestParameter"
        :query-max-results="queryMaxResults"
        :single="single"
        :value="cacheValue"
        close-on-click
        @change="onSelectionChanged"
      >
        <template #list-item="{_item, _cssClass, _itemClass, _indent, _itemLink, _skeleton, _selectable, _selected, _toggleElement}">
          <slot
            name="list-item"
            :item="_item"
            :css-class="_cssClass"
            :item-class="_itemClass"
            :indent="_indent"
            :selectable="_selectable"
            :selected="_selected"
            :toggle-element="_toggleElement"
          />
        </template>
      </objects-select-card-menu>

      <v-card-title
        :class="[indent ? 'px-4': 'px-0', sidebar ? 'pt-2 pb-0 pr-2' : 'py-3', {'pb-2': sidebar && showValues.length === 0}]"
        class="flex-nowrap"
      >
        <v-icon
          v-if="icon"
          :class="[hasErrors ? 'error--text': 'text--secondary']"
          class="ml-n1 mr-1"
          size="28"
        >
          {{ icon }}
        </v-icon>
        <div
          :class="[sidebar ? 'text-body-2' : 'text-body-1', hasErrors ? 'error--text': 'text--secondary']"
          class="mr-auto text-truncate"
        >
          {{ label }}
        </div>
        <v-btn
          v-if="hasErrors"
          :disabled="requestableLoading"
          color="error"
          small
          text
          @click.stop="saveSelection"
        >
          {{ $t('general.buttons.retry') }}
        </v-btn>
        <v-btn
          v-else
          :disabled="disabled || requestableLoading"
          color="primary"
          small
          text
          @click.stop="menuOpen = true"
        >
          {{ $t('general.buttons.change') }}
        </v-btn>
      </v-card-title>

      <slot
        v-if="showValues.length"
        :items="showValues"
        name="list"
      >
        <object-list-view
          :value="showValues"
          :indent="indent"
          :divider="divider"
        >
          <template #list-item="{_item, _cssClass, _itemClass, _indent, _itemLink, _skeleton}">
            <slot
              name="list-item"
              :item="_item"
              :css-class="_cssClass"
              :item-class="_itemClass"
              :indent="_indent"
              :item-link="_itemLink"
              :skeleton="_skeleton"
            />
          </template>
        </object-list-view>
      </slot>
      <slot
        v-else-if="$scopedSlots.empty"
        name="empty"
      />

      <v-progress-linear
        v-if="requestableLoading && !sidebar"
        height="2"
        indeterminate
      />
      <v-divider
        v-if="!requestableLoading && !outlined && !sidebar"
        :class="[{'error--text': hasErrors}]"
        class="custom-object-control__divider"
      />
    </v-card>
    <template
      v-if="sidebar"
      #append
    >
      <v-progress-linear
        v-if="requestableLoading"
        absolute
        bottom
        height="2"
        indeterminate
      />
    </template>
  </v-input>
</template>
