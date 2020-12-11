import Vue from 'vue'
import VueRouter from 'vue-router'

import AmbitionPage from 'pages/ambition'
import ProcessPage from 'pages/process'
import UserPage from 'pages/user'
import DossierPage from 'pages/dossier'

import AmbitionsListPage from 'pages/ambitions-list'
import ProcessesListPage from 'pages/processes-list'
import TasksListPage from 'pages/tasks-list'
import NotificationListPage from 'pages/notifications-list'
import SearchResultsListPage from 'pages/search-results-list'
import DossiersListPage from 'pages/dossiers-list'

import ErrorPage from 'pages/error'

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/',
      redirect: '/ambitions',
      name: 'home'
    },
    {
      path: '/ambitions/:ambitionId',
      name: 'ambition',
      component: AmbitionPage,
      props: (route) => ({
        ambitionId: parseInt(route.params.ambitionId)
      })
    },
    {
      path: '/processes/:processId',
      name: 'process',
      component: ProcessPage,
      props: (route) => ({
        processId: parseInt(route.params.processId)
      })
    },
    {
      path: '/processes/:processId/task/:taskId',
      name: 'task',
      component: ProcessPage,
      props: (route) => ({
        processId: parseInt(route.params.processId),
        taskId: parseInt(route.params.taskId)
      })
    },
    {
      path: '/task/:taskId',
      name: 'single_task',
      component: ProcessPage,
      props: (route) => ({
        taskId: parseInt(route.params.taskId)
      })
    },
    {
      path: '/ambitions',
      name: 'ambitions',
      component: AmbitionsListPage
    },
    {
      path: '/processes',
      name: 'processes',
      component: ProcessesListPage,
      props: (route) => ({
        query: route.query
      })
    },
    {
      path: '/tasks',
      name: 'tasks',
      component: TasksListPage,
      props: (route) => ({
        query: route.query
      })
    },
    {
      path: '/notifications',
      name: 'notifications',
      component: NotificationListPage
    },
    {
      path: '/users/:userId',
      name: 'user',
      component: UserPage,
      props: (route) => ({
        userId: parseInt(route.params.userId)
      })
    },
    {
      path: '/dossiers/:dossierId',
      name: 'dossier',
      component: DossierPage,
      props: (route) => ({
        dossierId: parseInt(route.params.dossierId)
      })
    },
    {
      path: '/dossiers',
      name: 'dossiers',
      component: DossiersListPage,
      props: (route) => ({
        query: route.query
      })
    },
    {
      path: '/search/:query',
      name: 'search',
      component: SearchResultsListPage,
      props: (route) => ({
        query: route.params.query
      })
    },
    {
      path: '*',
      component: ErrorPage
    }
  ]
})
