export default {
  object: {
    task: 'Aufgabe',
    process: 'Maßnahme',
    ofProcess: 'in Maßnahme',
    ambition: 'Ziel',
    user: 'Nutzer'
  },
  withSubject: {
    created: '{user} hat {object} erstellt',
    started: '{user} hat {object} gestartet',
    completed: '{user} hat {object} abgeschlossen',
    canceled: '{user} hat {object} abgebrochen',
    deleted: '{user} hat {object} gelöscht',
    reopened: '{user} hat {object} wiedereröffnet',
    assigned: {
      normal: '{user} hat {newValuePart} als Verantwortlichen zugewiesen {oldValuePart}',
      referenced: '{user} hat {newValuePart} als Verantwortlichen von {object} zugewiesen {oldValuePart}',
      newValuePart: '{newValue} als',
      oldValuePart: 'und {oldValue} als Verantwortlichen entfernt'
    },
    unassigned: {
      normal: '{user} hat {oldValue} als Verantwortlichen entfernt',
      referenced: '{user} hat {oldValue} als Verantwortlichen von {object} entfernt'
    },
    addedContributor: {
      normal: '{user} hat {newValue} als Teilnehmer hinzugefügt',
      referenced: '{user} hat {newValue} als Teilnehmer von {object} hinzugefügt'
    },
    removedContributor: {
      normal: '{user} hat {oldValue} als Teilnehmer entfernt',
      referenced: '{user} hat {oldValue} als Teilnehmer von {object} entfernt'
    },
    addedSuccessorProcess: {
      normal: '{user} hat {newValue} als Folgemaßnahme hinzugefügt',
      referenced: '{user} hat {newValue} als Folgemaßnahme von {object} hinzugefügt'
    },
    addedProcess: {
      normal: '{user} hat {newValue} hinzugefügt',
      referenced: '{user} hat {newValue} zu {object} hinzugefügt'
    },
    removedProcess: {
      normal: '{user} hat {oldValue} entfernt',
      referenced: '{user} hat {oldValue} aus {object} entfernt'
    },
    changedDueDate: {
      normal: '{user} hat das Fälligkeitsdatum {oldValuePart} {newValuePart} {deleteValuePart}',
      referenced: '{user} hat das Fälligkeitsdatum von {object} {oldValuePart} {newValuePart} {deleteValuePart}',
      newValuePart: 'auf {newValue} geändert',
      oldValuePart: 'von {oldValue}',
      deleteValuePart: 'gelöscht'
    },
    changedTitle: {
      normal: '{user} hat den Titel {oldValuePart} {newValuePart} {deleteValuePart}',
      referenced: '{user} hat den Titel von {object} {oldValuePart} {newValuePart} {deleteValuePart}',
      newValuePart: 'auf {newValue} geändert',
      oldValuePart: 'von {oldValue}',
      deleteValuePart: 'gelöscht'
    },
    changedVisibility: {
      normal: '{user} hat die Sichtbarkeit auf {newValue} geändert',
      referenced: '{user} hat die Sichtbarkeit von {object} auf {newValue} geändert'
    },
    changedSummary: {
      normal: '{user} hat die Beschreibung geändert',
      referenced: '{user} hat die Beschreibung von {object} geändert {mentionedPart}',
      mentioned: 'und Dich darin erwähnt'
    },
    commented: {
      referenced: {
        normal: 'schrieb einen Kommentar zu {object}',
        mentioned: 'hat Dich in einem Kommentar zu {object} erwähnt'
      }
    }
  },
  withoutSubject: {
    created: '{object} wurde erstellt',
    started: '{object} wurde gestartet',
    completed: '{object} wurde abgeschlossen',
    canceled: '{object} wurde abgebrochen',
    completedProcess: '{oldValue} aus {object} wurde abgeschlossen'
  }
}
