import Vue from 'vue'

Vue.mixin({
  beforeCreate () {
    const options = this.$options
    if (options.apiEndpoints) { this.$apiEndpoints = options.apiEndpoints } else if (options.parent && options.parent.$apiEndpoints) { this.$apiEndpoints = options.parent.$apiEndpoints }
  }
})

const API_BASE_URL = '/api/'

export default {
  ambitions: {
    index () { return API_BASE_URL + 'ambitions' },
    list () { return API_BASE_URL + 'ambitions/list' },
    get (id) { return API_BASE_URL + `ambitions/${id}` },
    activities (id) { return API_BASE_URL + `ambitions/${id}/activities` },
    create () { return API_BASE_URL + 'ambitions' },
    update (id) { return API_BASE_URL + `ambitions/${id}` },
    updatePrivateStatus (id) { return API_BASE_URL + `ambitions/${id}/update_private_status` },
    updateAssignee (id) { return API_BASE_URL + `ambitions/${id}/update_assignee` },
    updateContributors (id) { return API_BASE_URL + `ambitions/${id}/update_contributors` },
    updateProcesses (id) { return API_BASE_URL + `ambitions/${id}/update_processes` },
    close (id) { return API_BASE_URL + `ambitions/${id}/close` },
    reopen (id) { return API_BASE_URL + `ambitions/${id}/reopen` },
    destroy (id) { return API_BASE_URL + `ambitions/${id}` },
    comment (id) { return API_BASE_URL + `ambitions/${id}/comment` }
  },
  processDefinitions: {
    index () { return API_BASE_URL + 'process_definitions' }
  },
  processes: {
    index () { return API_BASE_URL + 'processes' },
    list () { return API_BASE_URL + 'processes/list' },
    get (id) { return API_BASE_URL + `processes/${id}` },
    activities (id) { return API_BASE_URL + `processes/${id}/activities` },
    create () { return API_BASE_URL + 'processes' },
    update (id) { return API_BASE_URL + `processes/${id}` },
    updatePrivateStatus (id) { return API_BASE_URL + `processes/${id}/update_private_status` },
    updateAssignee (id) { return API_BASE_URL + `processes/${id}/update_assignee` },
    updateContributors (id) { return API_BASE_URL + `processes/${id}/update_contributors` },
    updateAmbitions (id) { return API_BASE_URL + `processes/${id}/update_ambitions` },
    cancel (id) { return API_BASE_URL + `processes/${id}/cancel` },
    comment (id) { return API_BASE_URL + `processes/${id}/comment` }
  },
  tasks: {
    index () { return API_BASE_URL + 'tasks' },
    list () { return API_BASE_URL + 'tasks/list' },
    get (id) { return API_BASE_URL + `tasks/${id}` },
    activities (id) { return API_BASE_URL + `tasks/${id}/activities` },
    update (id) { return API_BASE_URL + `tasks/${id}` },
    updateAssignee (id) { return API_BASE_URL + `tasks/${id}/update_assignee` },
    updateContributors (id) { return API_BASE_URL + `tasks/${id}/update_contributors` },
    updateMarked (id) { return API_BASE_URL + `tasks/${id}/update_marked` },
    updateDueDate (id) { return API_BASE_URL + `tasks/${id}/update_due_date` },
    complete (id) { return API_BASE_URL + `tasks/${id}/complete` },
    comment (id) { return API_BASE_URL + `tasks/${id}/comment` },
    getData (id) { return API_BASE_URL + `tasks/${id}/data` },
    updateData (id) { return API_BASE_URL + `tasks/${id}/data` },
    createDocument (id) { return API_BASE_URL + `tasks/${id}/create_document` },
    updateDocument (id) { return API_BASE_URL + `tasks/${id}/update_document` },
    destroyDocument (id) { return API_BASE_URL + `tasks/${id}/destroy_document` }
  },
  users: {
    list () { return API_BASE_URL + 'users/list' },
    show (id) { return API_BASE_URL + `users/${id}` },
    info (id) { return API_BASE_URL + `users/${id}/info` }
  },
  notifications: {
    index () { return API_BASE_URL + 'notifications' },
    mark_all () { return API_BASE_URL + 'notifications/mark_all' },
    mark (id) { return API_BASE_URL + `notifications/${id}/mark` }
  },
  search: {
    fulltext () { return API_BASE_URL + 'search/fulltext' }
  },
  dossiers: {
    index () { return API_BASE_URL + 'dossiers' },
    list () { return API_BASE_URL + 'dossiers/list' },
    get (id) { return API_BASE_URL + `dossiers/${id}` },
    new () { return API_BASE_URL + 'dossiers/new' },
    create () { return API_BASE_URL + 'dossiers' },
    update (id) { return API_BASE_URL + `dossiers/${id}` },
    destroy (id) { return API_BASE_URL + `dossiers/${id}` },
    getReferences (id) { return API_BASE_URL + `dossiers/${id}/show_references` }
  },
  dossierDefinitions: {
    index () { return API_BASE_URL + 'dossier_definitions' }
  }
}
