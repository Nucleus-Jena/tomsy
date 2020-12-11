export default {
  model: {
    prop: 'visible',
    event: 'visibility-change'
  },
  props: {
    attach: {
      type: [Element, Object, String, Boolean],
      default: false
    },
    visible: {
      type: Boolean
    },
    closeOnClick: {
      type: Boolean
    },
    closeOnContentClick: {
      type: Boolean
    },
    nudgeBottom: {
      type: Number,
      default: 0
    },
    absolute: Boolean
  },
  data () {
    return {
      internalVisible: false
    }
  },
  methods: {
    closeMenuCard: function () {
      this.internalVisible = false
    },
    onMenuReturnValue: function () {
      this.$emit('visibility-change', false)
      this.onMenuCardClosed()
    },
    onMenuCardOpened: function () {
    },
    onMenuCardClosed: function () {
    }
  },
  computed: {
    attachElement: function () {
      if (this.attach) {
        if ((this.attach instanceof Object) && !(this.attach instanceof Element)) {
          return this.attach.$el
        } else {
          return this.attach
        }
      }

      return false
    }
  },
  watch: {
    visible: {
      handler (val) {
        this.internalVisible = this.visible
      },
      immediate: true
    },
    internalVisible: {
      handler (val) {
        if (val) {
          this.onMenuCardOpened()
        }
      }
    }
  }
}

/* <template>
    <v-menu :close-on-click="closeOnClick" :close-on-content-click="closeOnContentClick" :value="internalVisible"
            @update:return-value="onMenuReturnValue" transition="slide-y-transition"
            :attach="attach" z-index="1" min-width="100%" :nudge-bottom="nudgeBottom">
        <v-card :loading="loading">
          <slot></slot>
        </v-card>
    </v-menu>
</template> */
