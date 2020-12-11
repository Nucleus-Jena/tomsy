<script>
import Requestable, { requestablePropFactory } from 'mixins/requestable'
import Cacheable from 'mixins/cacheable'
import Menucardable from 'mixins/menucardable'
import ObjectListItem from 'list-items/object-list-item'
import debounce from 'lodash/debounce'
import findIndex from 'lodash/findIndex'
import xorBy from 'lodash/xorBy'
import cloneDeep from 'lodash/cloneDeep'
import map from 'lodash/map'

export default {
  name: 'ObjectsSelectCardMenu',
  components: { ObjectListItem },
  mixins: [Requestable, Cacheable, Menucardable],
  props: {
    ...requestablePropFactory().props,
    value: {
      type: Array,
      required: true
    },
    queryMaxResults: {
      type: Number,
      required: true
    },
    single: Boolean
  },
  data () {
    return {
      itemsTop: [],

      queryText: null,
      queryItems: []
    }
  },
  computed: {
    hintMessage: function () {
      if (this.queryText && this.queryItems.length < this.queryMaxResults) {
        return null
      } else {
        return 'Mehr Ergebnisse verfügbar. Bitte verfeinern Sie Ihre Suche.'
      }
    },
    cachedValueChanged: function () {
      return (this.value.length !== this.cacheValue.length) ||
          xorBy(this.value, this.cacheValue, 'id').length > 0
    }
  },
  methods: {
    onRequestSuccess: function (data) {
      this.queryItems = data
    },
    onMenuCardOpened: function () {
      this.createCacheValue()

      this.queryText = null
      this.query()
    },
    onMenuCardClosed: function () {
      this.cancelRequestable()
      this.resetRequestable()

      if (this.cachedValueChanged) {
        this.$emit('change', this.cacheValue)
      }
    },
    isSelected: function (item) {
      return findIndex(this.cacheValue, { id: item.id }) !== -1
    },
    toggleElement: function (item) {
      const index = findIndex(this.cacheValue, { id: item.id })
      if (index === -1) {
        if (this.single) {
          this.cacheValue.shift()
        }
        this.cacheValue.push(item)
      } else {
        this.cacheValue.splice(index, 1)
      }

      if (this.single) {
        this.closeMenuCard()
      }
    },
    query: function () {
      if (!this.queryText) {
        this.itemsTop = cloneDeep(this.cacheValue)
        this.request(this.requestParameter, {
          except: map(this.cacheValue, 'id'),
          query: '',
          max_result_count: this.queryMaxResults
        }, null, true)
      } else {
        this.itemsTop = []
        this.request(this.requestParameter, {
          except: [],
          query: this.queryText,
          max_result_count: this.queryMaxResults
        }, null, true)
      }
    },
    queryTextChanged: debounce(function () {
      this.query()
    }, 500)
  }
}
</script>
<template>
  <v-menu
    :attach="attachElement"
    :close-on-click="closeOnClick"
    :close-on-content-click="closeOnContentClick"
    :nudge-bottom="nudgeBottom"
    :value="internalVisible"
    transition="slide-y-transition"
    min-width="100%"
    z-index="3"
    @update:return-value="onMenuReturnValue"
  >
    <v-card>
      <div class="pt-4">
        <v-text-field
          v-model="queryText"
          :error-messages="errorMessage"
          :hint="hintMessage"
          autofocus
          class="mx-4"
          clearable
          label="Suche"
          outlined
          persistent-hint
          @input="queryTextChanged"
        />

        <v-divider />
        <v-list
          class="py-0 u-scroll-y"
          max-height="400"
        >
          <template v-if="itemsTop.length">
            <slot
              v-for="item in itemsTop"
              :_item="item"
              :_selected="isSelected(item)"
              :_toggle-element="toggleElement"
              _indent
              name="list-item"
              _selectable
            >
              <object-list-item
                :key="item.id"
                :selected="isSelected(item)"
                :value="item"
                indent
                selectable
                @click="toggleElement(item)"
              />
            </slot>
            <v-divider />
          </template>

          <template v-if="!requestableLoading">
            <template v-if="queryItems.length > 0">
              <slot
                v-for="item in queryItems"
                :_item="item"
                :_selected="isSelected(item)"
                :_toggle-element="toggleElement"
                _indent
                name="list-item"
                _selectable
              >
                <object-list-item
                  :key="item.id"
                  :selected="isSelected(item)"
                  :value="item"
                  indent
                  selectable
                  @click="toggleElement(item)"
                />
              </slot>
            </template>
            <v-list-item v-else>
              <v-list-item-content class="text-center">
                Keine Ergebnisse
              </v-list-item-content>
            </v-list-item>
          </template>
          <v-list-item v-else>
            <v-list-item-content class="text-center">
              <v-progress-circular
                color="primary"
                indeterminate
              />
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </div>
    </v-card>
  </v-menu>
</template>
