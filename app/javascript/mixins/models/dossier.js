export default {
  computed: {
    dossierBreadcrumbs () {
      return [
        { text: 'Dossiers', to: { name: 'dossiers' } },
        { text: this.dossier.definition.label, to: { name: 'dossiers', query: { dossier_definitions: [this.dossier.definition.id] } } },
        { text: `*${this.dossier.id}` }
      ]
    }
  }
}
