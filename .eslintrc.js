const INLINE_ELEMENTS = require('eslint-plugin-vue/lib/utils/inline-non-void-elements.json')

module.exports = {
  extends: [
    // add more generic rulesets here, such as:
    'standard',
    'plugin:vue/recommended'
  ],
  rules: {
    // override/add rules settings here, such as:
    // 'vue/no-unused-vars': 'error'
    // quotes: ["error", "double"] // We might want to add this as ONLY exception to aling with ruby standard

    'vue/multiline-html-element-content-newline': ['warn', {
      ignores: ['pre', 'textarea', 'router-link'].concat(INLINE_ELEMENTS),
      ignoreWhenEmpty: true,
      allowEmptyLines: false
    }]
  }
}
