# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_25_143130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "ambitions", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed", default: false, null: false
    t.text "description"
    t.boolean "private", default: false
    t.bigint "assignee_id"
    t.boolean "deleted", default: false, null: false
    t.datetime "state_updated_at", default: -> { "now()" }, null: false
    t.index ["assignee_id"], name: "index_ambitions_on_assignee_id"
    t.index ["title"], name: "index_ambitions_on_title"
  end

  create_table "ambitions_users", id: false, force: :cascade do |t|
    t.bigint "ambition_id", null: false
    t.bigint "user_id", null: false
    t.index ["ambition_id"], name: "index_ambitions_users_on_ambition_id"
    t.index ["user_id", "ambition_id"], name: "index_ambitions_users_on_user_id_and_ambition_id", unique: true
    t.index ["user_id"], name: "index_ambitions_users_on_user_id"
  end

  create_table "ambitions_workflow_processes", id: false, force: :cascade do |t|
    t.bigint "ambition_id", null: false
    t.bigint "workflow_process_id", null: false
    t.index ["ambition_id", "workflow_process_id"], name: "unique_index_ambitions_processes_join", unique: true
    t.index ["ambition_id"], name: "index_ambitions_workflow_processes_on_ambition_id"
    t.index ["workflow_process_id"], name: "index_ambitions_workflow_processes_on_workflow_process_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "message"
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "object_type", null: false
    t.bigint "object_id", null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["object_type", "object_id"], name: "index_comments_on_object_type_and_object_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "title", null: false
    t.string "type", null: false
    t.bigint "data_entity_id", null: false
    t.string "data_entity_field", null: false
    t.string "link_url"
    t.text "file_as_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "data_entity_type", default: "ProcessDataEntity"
    t.index ["data_entity_id", "data_entity_field"], name: "idx_documents_on_data_entity_id_and_field"
  end

  create_table "dossier_associations", force: :cascade do |t|
    t.bigint "dossier_id", null: false
    t.string "data_entity_type", null: false
    t.bigint "data_entity_id", null: false
    t.string "data_entity_field", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_entity_field"], name: "index_dossier_associations_on_data_entity_field"
    t.index ["data_entity_type", "data_entity_id"], name: "index_dossier_associations_on_data_entity_type_and_id"
    t.index ["dossier_id"], name: "index_dossier_associations_on_dossier_id"
  end

  create_table "dossier_definition_fields", force: :cascade do |t|
    t.bigint "definition_id", null: false
    t.string "identifier", null: false
    t.string "label", null: false
    t.integer "position", null: false
    t.integer "content_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "required", default: false, null: false
    t.boolean "recommended", default: false, null: false
    t.boolean "unique", default: false, null: false
    t.index ["definition_id", "identifier"], name: "index_dossier_definition_fields_on_definition_id_and_identifier", unique: true
    t.index ["definition_id", "position"], name: "index_dossier_definition_fields_on_definition_id_and_position", unique: true
    t.index ["definition_id"], name: "index_dossier_definition_fields_on_definition_id"
  end

  create_table "dossier_definitions", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "label", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "title_fields", default: []
    t.jsonb "subtitle_fields", default: []
    t.index ["identifier"], name: "index_dossier_definitions_on_identifier", unique: true
  end

  create_table "dossiers", force: :cascade do |t|
    t.bigint "definition_id", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "data", default: {}
    t.boolean "deleted", default: false, null: false
    t.index ["created_by_id"], name: "index_dossiers_on_created_by_id"
    t.index ["data"], name: "index_dossiers_on_data", using: :gin
    t.index ["definition_id"], name: "index_dossiers_on_definition_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "type", null: false
    t.string "object_type", null: false
    t.bigint "object_id", null: false
    t.bigint "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "data"
    t.index ["object_type", "object_id"], name: "index_events_on_object_type_and_object_id"
    t.index ["subject_id"], name: "index_events_on_subject_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "camunda_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups_workflow_process_definitions", id: false, force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "workflow_process_definition_id", null: false
    t.index ["group_id", "workflow_process_definition_id"], name: "unique_index_groups_process_definitions_join", unique: true
    t.index ["group_id"], name: "index_groups_workflow_process_definitions_on_group_id"
    t.index ["workflow_process_definition_id"], name: "index_groups_workflow_pd_on_workflow_process_definition_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "marked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_notifications_on_event_id"
    t.index ["user_id", "event_id"], name: "index_notifications_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "process_associations", force: :cascade do |t|
    t.bigint "process_id", null: false
    t.string "data_entity_type", null: false
    t.bigint "data_entity_id", null: false
    t.string "data_entity_field", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_entity_field"], name: "index_process_associations_on_data_entity_field"
    t.index ["data_entity_type", "data_entity_id"], name: "index_process_associations_on_data_entity_type_and_id"
    t.index ["process_id"], name: "index_process_associations_on_process_id"
  end

  create_table "process_data_entities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.jsonb "data", default: {}
  end

  create_table "user_groups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.index ["group_id", "user_id"], name: "index_user_groups_on_group_id_and_user_id", unique: true
    t.index ["user_id", "group_id"], name: "index_user_groups_on_user_id_and_group_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.string "camunda_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "camunda_token"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_workflow_processes", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "workflow_process_id", null: false
    t.index ["user_id", "workflow_process_id"], name: "unique_index_users_process_join", unique: true
    t.index ["user_id"], name: "index_users_workflow_processes_on_user_id"
    t.index ["workflow_process_id"], name: "index_users_workflow_processes_on_workflow_process_id"
  end

  create_table "users_workflow_tasks", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "workflow_task_id", null: false
    t.index ["user_id", "workflow_task_id"], name: "unique_index_users_tasks_join", unique: true
    t.index ["user_id"], name: "index_users_workflow_tasks_on_user_id"
    t.index ["workflow_task_id"], name: "index_users_workflow_tasks_on_workflow_task_id"
  end

  create_table "users_workflow_tasks_marked", id: false, force: :cascade do |t|
    t.bigint "workflow_task_id", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "workflow_task_id"], name: "idx_users_workflow_tasks_marked_on_user_id_and_workflow_task_id", unique: true
    t.index ["user_id"], name: "index_users_workflow_tasks_marked_on_user_id"
    t.index ["workflow_task_id"], name: "index_users_workflow_tasks_marked_on_workflow_task_id"
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  create_table "workflow_flow_object_definitions", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.bigint "workflow_process_definition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.string "type", null: false
    t.index ["key", "workflow_process_definition_id"], name: "idx_wf_task_defs_on_camunda_id_and_wf_process_definition_id", unique: true
    t.index ["workflow_process_definition_id"], name: "idx_workflow_task_definitions_on_workflow_process_definition_id"
  end

  create_table "workflow_process_definitions", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label_prefix"
    t.jsonb "model", default: {}
    t.text "description"
    t.index ["key"], name: "index_workflow_process_definitions_on_key", unique: true
    t.index ["label_prefix"], name: "index_workflow_process_definitions_on_label_prefix", unique: true
    t.index ["name"], name: "index_workflow_process_definitions_on_name", unique: true
  end

  create_table "workflow_processes", force: :cascade do |t|
    t.string "camunda_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "data_entity_type"
    t.bigint "data_entity_id"
    t.bigint "workflow_process_definition_id", null: false
    t.string "state", null: false
    t.text "cancel_info"
    t.datetime "ended_at"
    t.bigint "cancel_user_id"
    t.string "title"
    t.bigint "assignee_id"
    t.boolean "private", default: false
    t.bigint "predecessor_process_id"
    t.text "description"
    t.datetime "state_updated_at", default: -> { "now()" }, null: false
    t.index ["assignee_id"], name: "index_workflow_processes_on_assignee_id"
    t.index ["cancel_user_id"], name: "index_workflow_processes_on_cancel_user_id"
    t.index ["data_entity_type", "data_entity_id"], name: "index_workflow_processes_on_data_entity_type_and_data_entity_id"
    t.index ["predecessor_process_id"], name: "index_workflow_processes_on_predecessor_process_id"
    t.index ["workflow_process_definition_id"], name: "index_workflow_processes_on_workflow_process_definition_id"
  end

  create_table "workflow_sequence_flows", force: :cascade do |t|
    t.string "from_object_type", null: false
    t.bigint "from_object_id", null: false
    t.string "to_object_type", null: false
    t.bigint "to_object_id", null: false
    t.bigint "workflow_process_definition_id", null: false
    t.index ["workflow_process_definition_id", "from_object_id", "to_object_id"], name: "workflow_sequence_flows_only_connect_once_per_direction", unique: true
  end

  create_table "workflow_tasks", force: :cascade do |t|
    t.string "camunda_id"
    t.string "state", null: false
    t.date "due_at"
    t.bigint "workflow_process_id", null: false
    t.bigint "assignee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ended_at"
    t.bigint "workflow_task_definition_id", null: false
    t.datetime "state_updated_at", default: -> { "now()" }, null: false
    t.text "description"
    t.index ["assignee_id"], name: "index_workflow_tasks_on_assignee_id"
    t.index ["workflow_process_id"], name: "index_workflow_tasks_on_workflow_process_id"
  end

  add_foreign_key "ambitions", "users", column: "assignee_id"
  add_foreign_key "comments", "users", column: "author_id"
  add_foreign_key "dossier_associations", "dossiers"
  add_foreign_key "dossier_definition_fields", "dossier_definitions", column: "definition_id"
  add_foreign_key "dossiers", "dossier_definitions", column: "definition_id"
  add_foreign_key "dossiers", "users", column: "created_by_id"
  add_foreign_key "events", "users", column: "subject_id"
  add_foreign_key "notifications", "events"
  add_foreign_key "notifications", "users"
  add_foreign_key "process_associations", "workflow_processes", column: "process_id"
  add_foreign_key "workflow_flow_object_definitions", "workflow_process_definitions"
  add_foreign_key "workflow_processes", "users", column: "assignee_id"
  add_foreign_key "workflow_processes", "users", column: "cancel_user_id"
  add_foreign_key "workflow_processes", "workflow_process_definitions"
  add_foreign_key "workflow_processes", "workflow_processes", column: "predecessor_process_id"
  add_foreign_key "workflow_tasks", "users", column: "assignee_id"
  add_foreign_key "workflow_tasks", "workflow_processes"
end
