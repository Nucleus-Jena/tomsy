if object.nil?
  json.null!
else
  noaccess = current_user.cannot?(:read, object)

  json.id object.id
  json.type object.class.name.demodulize.downcase
  json.label object.reference_label(noaccess)
  json.noaccess noaccess
  json.deleted object.respond_to?(:deleted?) && object.deleted?
end
