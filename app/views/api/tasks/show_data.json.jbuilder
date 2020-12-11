json.id @data_entity.id
json.items do
  json.partial! partial: "api/tasks/data_attribute_item", collection: @data_attributes, as: :data_attribute, locals: {data_entity_id: @data_entity.id}
end
