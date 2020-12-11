<script>
export default {
  name: 'AvatarComponent',
  props: {
    text: { type: String, default: undefined },
    icon: { type: String, default: undefined },
    image: { type: String, default: undefined },
    tooltipTitle: { type: String, default: undefined },
    tooltipSubtitle: { type: String, default: undefined },
    skeleton: Boolean,
    list: Boolean,
    active: Boolean,
    white: Boolean,
    size: {
      type: Number,
      default: 36
    }
  },
  data () {
    return {
      activator: undefined
    }
  },
  computed: {
    backgroundColor () {
      if (this.icon) {
        return 'grey lighten-4'
      } else {
        if (this.white) {
          return 'white'
        } else {
          return this.active ? 'primary' : 'blue-grey lighten-4'
        }
      }
    },
    textColor () {
      if (this.white) {
        return 'primary--text'
      } else {
        return 'white--text'
      }
    }
  },
  mounted () {
    this.activator = this.$refs.avatar
  }
}
</script>
<template>
  <v-skeleton-loader
    v-if="skeleton"
    class="custom-skeleton-loader"
    type="avatar"
  />

  <v-list-item-avatar
    v-else-if="list"
    ref="avatar"
    :color="backgroundColor"
    :size="size"
  >
    <img
      v-if="image"
      :src="image"
      alt="avatar image"
    >
    <v-icon
      v-else-if="icon"
      color="grey"
    >
      {{ icon }}
    </v-icon>
    <span
      v-else
      class="text-subtitle-2"
      :class="textColor"
    >{{ text }}</span>

    <v-tooltip
      v-if="tooltipTitle || tooltipSubtitle"
      :activator="activator"
      top
    >
      <div class="text-subtitle-2">
        {{ tooltipTitle }}
      </div>
      <div>{{ tooltipSubtitle }}</div>
    </v-tooltip>
  </v-list-item-avatar>

  <v-avatar
    v-else
    ref="avatar"
    :color="backgroundColor"
    :size="size"
  >
    <img
      v-if="image"
      :src="image"
      alt="avatar image"
    >
    <v-icon
      v-else-if="icon"
      color="grey lighten-1"
    >
      {{ icon }}
    </v-icon>
    <span
      v-else
      class="text-subtitle-2"
      :class="textColor"
    >{{ text }}</span>

    <v-tooltip
      v-if="tooltipTitle || tooltipSubtitle"
      :activator="activator"
      top
    >
      <div class="text-subtitle-2">
        {{ tooltipTitle }}
      </div>
      <div>{{ tooltipSubtitle }}</div>
    </v-tooltip>
  </v-avatar>
</template>
