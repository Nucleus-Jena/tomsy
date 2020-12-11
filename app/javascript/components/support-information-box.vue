<script>
import ObjectListView from 'data-views/object-list-view'
import DossierListItem from 'list-items/dossier-list-item'
import DocumentListView from 'data-views/document-list-view'
import { formatDate } from 'helpers/date'
import find from 'lodash/find'
import result from 'lodash/result'
import isNil from 'lodash/isNil'

export default {
  name: 'SupportInformationBox',
  components: { ObjectListView, DossierListItem, DocumentListView },
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  computed: {
    label () {
      return this.data.label
    },
    valueType () {
      return this.data.parameter.valueType
    },
    valueParameter () {
      return this.data.parameter.valueParameter
    },
    value () {
      return this.data.value
    },
    hasValue () {
      return !isNil(this.value)
    },
    valueAsDate () {
      return formatDate(new Date(this.value))
    },
    hasValueWrapperPadding () {
      switch (this.valueType) {
        case 'has_many_dossiers': return false
        case 'has_one_dossier': return false
        case 'has_many_files': return false
        case 'has_one_file': return false
        default: return true
      }
    }
  },
  methods: {
    enumLabelFor (id) {
      return result(find(this.valueParameter.values, { id: id }), 'label')
    }
  }
}
</script>
<template>
  <div class="support-info-box py-5">
    <label
      v-if="label"
      class="d-block text-body-2 text--secondary px-6 mb-2"
    >{{ label }}</label>
    <div
      v-if="hasValue"
      class="text--primary"
      :class="{'px-6': hasValueWrapperPadding }"
    >
      <template v-if="valueType === 'string' || valueType === 'text'">
        {{ value }}
      </template>
      <template v-else-if="valueType === 'date' || valueType === 'datetime'">
        {{ valueAsDate }}
      </template>
      <template v-else-if="valueType === 'enum'">
        <div
          v-for="(enumId, index) in value"
          :key="enumId"
          class="d-flex align-center"
          :class="{'mb-1': index < value.length - 1}"
        >
          <v-icon class="text--primary mr-2">
            mdi-check-box-outline
          </v-icon>
          {{ enumLabelFor(enumId) }}
        </div>
      </template>
      <template v-else-if="valueType === 'boolean'">
        {{ value ? 'Ja' : 'Nein' }}
      </template>
      <template v-else-if="valueType === 'has_many_dossiers' || valueType === 'has_one_dossier'">
        <object-list-view
          :value="valueType === 'has_one_dossier' ? [value] : value"
          indent
          item-class="px-6"
        >
          <template #list-item="{_item, _cssClass, _itemClass, _indent, _itemLink, _skeleton}">
            <dossier-list-item
              :key="_item.id"
              :class="_cssClass"
              :item-class="_itemClass"
              :indent="_indent"
              :skeleton="_skeleton"
              :value="_item"
              :item-link="_itemLink"
              :to="{name: 'dossier', params: { dossierId: _item.id }}"
            />
          </template>
        </object-list-view>
      </template>
      <template v-else-if="valueType === 'has_many_files' || valueType === 'has_one_file'">
        <document-list-view
          :value="value"
          item-class="px-6"
        />
      </template>
    </div>
  </div>
</template>
<style>
  .support-info-box {
    background-color: #fff9f0;
  }
</style>
