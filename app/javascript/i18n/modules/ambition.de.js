export default {
  state: {
    open: 'Eröffnet',
    closed: 'Abgeschlossen'
  },
  openProcessesCount: '{count} offene Maßnahme | {count} offene Maßnahmen',
  detailActions: {
    close: 'Ziel abschließen',
    reopen: 'Ziel wiedereröffnen',
    delete: 'Ziel löschen'
  },
  closeDialog: {
    title: {
      standard: 'Ziel abschließen?',
      openProcesses: 'Ziel mit offenen Maßnahmen abschließen?',
      noAccessProcesses: 'Ziel mit unbekannten Maßnahmen abschließen?'
    },
    text: {
      standard: 'Schließen Sie das Ziel ab, wenn das Vorhaben erreicht ist. Abgeschlossene Ziele können später wiedereröffnet werden.',
      openProcesses: 'Das Ziel beinhaltet Maßnahmen, die noch nicht abgeschlossen wurden. Schließen Sie das Ziel ab, wenn das Vorhaben trotzdem erreich ist. Abgeschlossene Ziele können später wiedereröffnet werden.',
      noAccessProcesses: 'Das Ziel beinhaltet Maßnahmen, auf die Sie keinen Zugriff haben. Schließen Sie das Ziel nur ab, wenn Sie sicher sind, dass das Vorhaben trotzdem erreicht ist. Abgeschlossene Ziele können später wiedereröffnet werden.'
    },
    buttonOk: 'Ziel abschließen'
  },
  deleteDialog: {
    title: 'Ziel löschen?',
    text: 'Löschen Sie das Ziel, wenn Sie sicher sind, dass dieses Ziel nicht mehr benöigt wird. Gelöschte Ziele sind unwiederbringlich verloren.',
    buttonOk: 'Ziel löschen'
  }
}
