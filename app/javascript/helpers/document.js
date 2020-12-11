import compact from 'lodash/compact'
import round from 'lodash/round'
import { formatDateTime } from 'helpers/date'

const DOCUMENT_TYPE_LINK = 'link'
const DOCUMENT_TYPE_FILE = 'file'

export function isLink (document) {
  return document.type === DOCUMENT_TYPE_LINK
}

export function isFile (document) {
  return document.type === DOCUMENT_TYPE_FILE
}

export function updatedAtLocalized (document) {
  if (document.updatedAt) {
    return formatDateTime(new Date(document.updatedAt))
  }

  return null
}

export function icon (document) {
  switch (document.type) {
    case DOCUMENT_TYPE_LINK: return 'mdi-file-document-outline'
    case DOCUMENT_TYPE_FILE: return 'mdi-file-link-outline'
    default: return null
  }
}

export function url (document) {
  switch (document.type) {
    case DOCUMENT_TYPE_LINK: return document.linkUrl
    case DOCUMENT_TYPE_FILE: return document.fileUrl
    default: return null
  }
}

export function subtitleElements (document) {
  switch (document.type) {
    case DOCUMENT_TYPE_LINK: return compact([document.linkUrl, updatedAtLocalized(document)])
    case DOCUMENT_TYPE_FILE: return compact([document.fileName, fileSizeString(document.fileSize), updatedAtLocalized(document)])
    default: return null
  }
}

export function filePlaceholder (document) {
  if (document.fileName && document.fileSize) {
    return `${document.fileName} (${fileSizeString(document.fileSize)})`
  }

  return null
}

function fileSizeString (filesize) {
  if (filesize) {
    if (filesize >= 1000) {
      if (filesize > 1000000) {
        return `${round(filesize / 1000000)} MB`
      } else {
        return `${round(filesize / 1000)} kB`
      }
    } else {
      return `${filesize} Byte`
    }
  } else {
    return ''
  }
}

export function createLinkDocument (dataEntityField) {
  return createDocument(dataEntityField, DOCUMENT_TYPE_LINK)
}

export function createFileDocument (dataEntityField) {
  return createDocument(dataEntityField, DOCUMENT_TYPE_FILE)
}

function createDocument (dataEntityField, type) {
  switch (type) {
    case DOCUMENT_TYPE_LINK:
      return {
        dataEntityField: dataEntityField,
        type: type,
        title: '',
        linkUrl: ''
      }
    case DOCUMENT_TYPE_FILE:
      return {
        dataEntityField: dataEntityField,
        type: type,
        title: '',
        file: null
      }
  }
}
