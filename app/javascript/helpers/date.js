import { de } from 'date-fns/locale'
import { formatDistanceToNow, format } from 'date-fns'

const locales = { de }
const currentLocaleId = 'de'

export function distanceDate (date) {
  return formatDistanceToNow(date, { locale: locales[currentLocaleId], addSuffix: true })
}

export function formatDateTime (date) {
  return format(date, 'Pp', { locale: locales[currentLocaleId] })
}

export function formatDate (date) {
  return format(date, 'P', { locale: locales[currentLocaleId] })
}
