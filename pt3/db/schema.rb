# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_22_120400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_items", force: :cascade do |t|
    t.integer "actionitemid"
    t.text "description"
    t.string "openedby"
    t.string "assignedto"
    t.string "status"
    t.text "note"
    t.bigint "item_id"
    t.bigint "project_id"
    t.bigint "review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.index ["archive_id"], name: "index_action_items_on_archive_id"
    t.index ["item_id"], name: "index_action_items_on_item_id"
    t.index ["organization"], name: "index_action_items_on_organization"
    t.index ["project_id"], name: "index_action_items_on_project_id"
    t.index ["review_id"], name: "index_action_items_on_review_id"
  end

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

  create_table "archives", force: :cascade do |t|
    t.string "name", null: false
    t.string "full_id", null: false
    t.string "description", null: false
    t.string "revision", null: false
    t.string "version", null: false
    t.datetime "archived_at", null: false
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.string "pact_version"
    t.string "archive_type"
    t.integer "item_id"
    t.integer "archive_project_id"
    t.integer "archive_item_id"
    t.string "archive_item_ids"
    t.integer "element_id"
    t.index ["archive_type"], name: "index_archives_on_archive_type"
    t.index ["project_id"], name: "index_archives_on_project_id"
  end

  create_table "change_sessions", force: :cascade do |t|
    t.integer "session_id", null: false
    t.bigint "data_change_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.index ["data_change_id"], name: "index_change_sessions_on_data_change_id"
    t.index ["organization"], name: "index_change_sessions_on_organization"
    t.index ["session_id"], name: "index_change_sessions_on_session_id"
  end

  create_table "checklist_items", force: :cascade do |t|
    t.integer "clitemid"
    t.bigint "review_id"
    t.bigint "document_id"
    t.text "description"
    t.text "note"
    t.string "reference"
    t.string "minimumdal"
    t.text "supplements"
    t.string "status"
    t.string "evaluator"
    t.date "evaluation_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.boolean "assigned"
    t.bigint "user_id"
    t.string "version"
    t.index ["archive_id"], name: "index_checklist_items_on_archive_id"
    t.index ["document_id"], name: "index_checklist_items_on_document_id"
    t.index ["organization"], name: "index_checklist_items_on_organization"
    t.index ["review_id"], name: "index_checklist_items_on_review_id"
    t.index ["user_id"], name: "index_checklist_items_on_user_id"
  end

  create_table "code_checkmark_hits", force: :cascade do |t|
    t.bigint "code_checkmark_id", null: false
    t.datetime "hit_at", precision: 6
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_checkmark_id"], name: "index_code_checkmark_hits_on_code_checkmark_id"
  end

  create_table "code_checkmarks", force: :cascade do |t|
    t.integer "checkmark_id", null: false
    t.bigint "source_code_id", null: false
    t.string "filename", null: false
    t.integer "line_number", null: false
    t.string "code_statement"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checkmark_id", "filename", "line_number"], name: "index_checkmarks_on_id_filename_and_line_number", unique: true
    t.index ["filename", "checkmark_id"], name: "index_code_checkmarks_on_filename_and_checkmark_id", unique: true
    t.index ["source_code_id"], name: "index_code_checkmarks_on_source_code_id"
  end

  create_table "code_conditional_blocks", force: :cascade do |t|
    t.bigint "source_code_id", null: false
    t.string "filename", null: false
    t.integer "start_line_number", null: false
    t.integer "end_line_number", null: false
    t.string "condition"
    t.boolean "offset"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_code_id", "filename", "start_line_number", "end_line_number"], name: "index_blocks_on_source_code_filename_and_line_numbers", unique: true
    t.index ["source_code_id"], name: "index_code_conditional_blocks_on_source_code_id"
  end

  create_table "constants", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "label", "value"], name: "index_constants_on_name_and_label_and_value", unique: true
  end

  create_table "data_changes", force: :cascade do |t|
    t.string "changed_by", null: false
    t.string "table_name", null: false
    t.integer "table_id", null: false
    t.string "action", null: false
    t.datetime "performed_at", null: false
    t.json "record_attributes"
    t.boolean "rolled_back"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.string "change_type"
    t.index ["changed_by", "table_name", "table_id", "action", "performed_at", "change_type"], name: "data_changes_primary_index", unique: true
    t.index ["organization"], name: "index_data_changes_on_organization"
  end

  create_table "document_attachments", force: :cascade do |t|
    t.bigint "document_id"
    t.bigint "item_id"
    t.bigint "project_id"
    t.string "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.datetime "upload_date"
    t.index ["archive_id"], name: "index_document_attachments_on_archive_id"
    t.index ["document_id"], name: "index_document_attachments_on_document_id"
    t.index ["item_id"], name: "index_document_attachments_on_item_id"
    t.index ["organization"], name: "index_document_attachments_on_organization"
    t.index ["project_id"], name: "index_document_attachments_on_project_id"
  end

  create_table "document_comments", force: :cascade do |t|
    t.integer "commentid"
    t.text "comment"
    t.string "docrevision"
    t.datetime "datemodified"
    t.string "status"
    t.string "requestedby"
    t.string "assignedto"
    t.bigint "item_id"
    t.bigint "project_id"
    t.bigint "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.string "draft_revision"
    t.index ["archive_id"], name: "index_document_comments_on_archive_id"
    t.index ["document_id"], name: "index_document_comments_on_document_id"
    t.index ["item_id"], name: "index_document_comments_on_item_id"
    t.index ["organization"], name: "index_document_comments_on_organization"
    t.index ["project_id"], name: "index_document_comments_on_project_id"
  end

  create_table "document_types", force: :cascade do |t|
    t.string "document_code"
    t.string "description"
    t.string "item_types"
    t.string "dal_levels"
    t.string "control_category"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_code", "item_types", "dal_levels", "control_category"], name: "index_document_types_on_type_item_types_dals_control_category", unique: true
    t.index ["organization"], name: "index_document_types_on_organization"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "document_id"
    t.string "docid"
    t.text "name"
    t.string "category"
    t.string "revision"
    t.string "draft_revision"
    t.string "document_type"
    t.string "review_status"
    t.date "revdate"
    t.integer "version"
    t.bigint "item_id"
    t.bigint "project_id"
    t.bigint "review_id"
    t.bigint "parent_id"
    t.string "file_path"
    t.string "file_type"
    t.integer "doccomment_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.datetime "upload_date"
    t.index ["archive_id"], name: "index_documents_on_archive_id"
    t.index ["document_id"], name: "index_documents_on_document_id"
    t.index ["item_id"], name: "index_documents_on_item_id"
    t.index ["organization"], name: "index_documents_on_organization"
    t.index ["parent_id"], name: "index_documents_on_parent_id"
    t.index ["project_id"], name: "index_documents_on_project_id"
    t.index ["review_id"], name: "index_documents_on_review_id"
  end

  create_table "function_items", force: :cascade do |t|
    t.integer "function_item_id"
    t.string "full_id"
    t.integer "project_id"
    t.integer "item_id"
    t.integer "source_code_id"
    t.string "filename"
    t.integer "line_number"
    t.string "calling_function"
    t.string "calling_parameters"
    t.integer "called_by"
    t.string "function"
    t.string "function_parameters"
    t.string "organization"
    t.index ["called_by"], name: "index_function_items_on_called_by"
    t.index ["full_id"], name: "index_function_items_on_full_id", unique: true
    t.index ["item_id"], name: "index_function_items_on_item_id"
    t.index ["project_id"], name: "index_function_items_on_project_id"
    t.index ["source_code_id", "filename", "line_number"], name: "index_function_items_on_source_code_id_filename_line_number", unique: true
  end

  create_table "github_accesses", force: :cascade do |t|
    t.text "username"
    t.text "password"
    t.text "token"
    t.bigint "user_id"
    t.text "last_accessed_repository"
    t.text "last_accessed_branch"
    t.text "last_accessed_folder"
    t.text "last_accessed_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.string "repository_url"
    t.index ["id"], name: "index_github_accesses_on_id"
    t.index ["organization"], name: "index_github_accesses_on_organization"
    t.index ["user_id"], name: "index_github_accesses_on_user_id"
  end

  create_table "gitlab_accesses", force: :cascade do |t|
    t.text "username"
    t.text "password"
    t.text "token"
    t.bigint "user_id"
    t.text "last_accessed_repository"
    t.text "last_accessed_branch"
    t.text "last_accessed_folder"
    t.text "last_accessed_file"
    t.string "url"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_gitlab_accesses_on_id"
    t.index ["organization"], name: "index_gitlab_accesses_on_organization"
    t.index ["user_id"], name: "index_gitlab_accesses_on_user_id"
  end

  create_table "high_level_requirements", force: :cascade do |t|
    t.integer "reqid", null: false
    t.text "full_id"
    t.text "description"
    t.text "category"
    t.text "verification_method"
    t.boolean "safety"
    t.boolean "robustness"
    t.boolean "derived"
    t.string "testmethod"
    t.integer "version"
    t.bigint "item_id"
    t.bigint "project_id"
    t.text "system_requirement_associations"
    t.text "derived_justification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.string "high_level_requirement_associations"
    t.boolean "soft_delete"
    t.bigint "document_id"
    t.bigint "model_file_id"
    t.index ["archive_id"], name: "index_high_level_requirements_on_archive_id"
    t.index ["document_id"], name: "index_high_level_requirements_on_document_id"
    t.index ["full_id", "project_id", "item_id", "archive_id"], name: "index_hlrs_on_full_id_and_project_id_and_item_id_and_archive_id", unique: true
    t.index ["item_id"], name: "index_high_level_requirements_on_item_id"
    t.index ["model_file_id"], name: "index_high_level_requirements_on_model_file_id"
    t.index ["organization"], name: "index_high_level_requirements_on_organization"
    t.index ["project_id"], name: "index_high_level_requirements_on_project_id"
    t.index ["reqid", "project_id", "item_id", "archive_id"], name: "index_hlrs_on_reqid_and_project_id_and_item_id_and_archive_id", unique: true
  end

  create_table "hlr_hlrs", id: false, force: :cascade do |t|
    t.integer "high_level_requirement_id"
    t.integer "referenced_high_level_requirement_id"
    t.index ["high_level_requirement_id"], name: "index_hlr_hlrs_on_high_level_requirement_id"
    t.index ["referenced_high_level_requirement_id"], name: "index_hlr_hlrs_on_referenced_high_level_requirement_id"
  end

  create_table "hlr_llrs", id: false, force: :cascade do |t|
    t.integer "high_level_requirement_id"
    t.integer "low_level_requirement_id"
    t.index ["high_level_requirement_id"], name: "index_hlr_llrs_on_high_level_requirement_id"
    t.index ["low_level_requirement_id"], name: "index_hlr_llrs_on_low_level_requirement_id"
  end

  create_table "hlr_mds", id: false, force: :cascade do |t|
    t.integer "high_level_requirement_id"
    t.integer "module_description_id"
    t.index ["high_level_requirement_id"], name: "index_hlr_mds_on_high_level_requirement_id"
    t.index ["module_description_id"], name: "index_hlr_mds_on_module_description_id"
  end

  create_table "hlr_mfs", id: false, force: :cascade do |t|
    t.bigint "high_level_requirement_id", null: false
    t.bigint "model_file_id", null: false
    t.index ["high_level_requirement_id", "model_file_id"], name: "index_hlr_mfs_on_high_level_requirement_id_and_model_file_id"
    t.index ["model_file_id", "high_level_requirement_id"], name: "index_hlr_mfs_on_model_file_id_and_high_level_requirement_id"
  end

  create_table "hlr_scs", id: false, force: :cascade do |t|
    t.integer "high_level_requirement_id"
    t.integer "source_code_id"
    t.index ["high_level_requirement_id"], name: "index_hlr_scs_on_high_level_requirement_id"
    t.index ["source_code_id"], name: "index_hlr_scs_on_source_code_id"
  end

  create_table "hlr_tcs", id: false, force: :cascade do |t|
    t.integer "high_level_requirement_id"
    t.integer "test_case_id"
    t.index ["high_level_requirement_id"], name: "index_hlr_tcs_on_high_level_requirement_id"
    t.index ["test_case_id"], name: "index_hlr_tcs_on_test_case_id"
  end

  create_table "hlr_tps", id: false, force: :cascade do |t|
    t.integer "high_level_requirement_id"
    t.integer "test_procedure_id"
    t.index ["high_level_requirement_id"], name: "index_hlr_tps_on_high_level_requirement_id"
    t.index ["test_procedure_id"], name: "index_hlr_tps_on_test_procedure_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "itemtype"
    t.string "identifier"
    t.string "level"
    t.bigint "project_id"
    t.integer "hlr_count", default: 0
    t.integer "llr_count", default: 0
    t.integer "review_count", default: 0
    t.integer "tc_count", default: 0
    t.integer "sc_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.string "high_level_requirements_prefix"
    t.string "low_level_requirements_prefix"
    t.string "source_code_prefix"
    t.string "test_case_prefix"
    t.string "test_procedure_prefix"
    t.integer "tp_count"
    t.string "model_file_prefix"
    t.text "module_description_prefix"
    t.index ["archive_id"], name: "index_items_on_archive_id"
    t.index ["organization"], name: "index_items_on_organization"
    t.index ["project_id"], name: "index_items_on_project_id"
  end

  create_table "licensees", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.text "description"
    t.date "setup_date"
    t.date "license_date"
    t.string "license_type"
    t.date "renewal_date"
    t.string "administrator"
    t.text "contact_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_emails"
    t.string "database"
    t.string "encrypted_password"
  end

  create_table "llr_mds", id: false, force: :cascade do |t|
    t.integer "low_level_requirement_id"
    t.integer "module_description_id"
    t.index ["low_level_requirement_id"], name: "index_llr_mds_on_low_level_requirement_id"
    t.index ["module_description_id"], name: "index_llr_mds_on_module_description_id"
  end

  create_table "llr_mfs", id: false, force: :cascade do |t|
    t.bigint "low_level_requirement_id", null: false
    t.bigint "model_file_id", null: false
    t.index ["low_level_requirement_id", "model_file_id"], name: "index_llr_mfs_on_low_level_requirement_id_and_model_file_id"
    t.index ["model_file_id", "low_level_requirement_id"], name: "index_llr_mfs_on_model_file_id_and_low_level_requirement_id"
  end

  create_table "llr_scs", id: false, force: :cascade do |t|
    t.integer "low_level_requirement_id"
    t.integer "source_code_id"
    t.index ["low_level_requirement_id"], name: "index_llr_scs_on_low_level_requirement_id"
    t.index ["source_code_id"], name: "index_llr_scs_on_source_code_id"
  end

  create_table "llr_tcs", id: false, force: :cascade do |t|
    t.integer "low_level_requirement_id"
    t.integer "test_case_id"
    t.index ["low_level_requirement_id"], name: "index_llr_tcs_on_low_level_requirement_id"
    t.index ["test_case_id"], name: "index_llr_tcs_on_test_case_id"
  end

  create_table "llr_tps", id: false, force: :cascade do |t|
    t.integer "low_level_requirement_id"
    t.integer "test_procedure_id"
    t.index ["low_level_requirement_id"], name: "index_llr_tps_on_low_level_requirement_id"
    t.index ["test_procedure_id"], name: "index_llr_tps_on_test_procedure_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "log_category"
    t.datetime "error_time"
    t.string "log_contents"
    t.integer "log_id"
    t.text "log_sha"
    t.string "log_type"
    t.text "raw_line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "low_level_requirements", force: :cascade do |t|
    t.integer "reqid"
    t.text "full_id"
    t.text "description"
    t.text "category"
    t.text "verification_method"
    t.boolean "safety"
    t.boolean "derived"
    t.integer "version"
    t.bigint "item_id"
    t.bigint "project_id"
    t.text "high_level_requirement_associations"
    t.text "derived_justification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.boolean "soft_delete"
    t.bigint "document_id"
    t.bigint "model_file_id"
    t.text "module_description"
    t.index ["archive_id"], name: "index_low_level_requirements_on_archive_id"
    t.index ["document_id"], name: "index_low_level_requirements_on_document_id"
    t.index ["full_id", "project_id", "item_id", "archive_id"], name: "index_llrs_on_full_id_and_project_id_and_item_id_and_archive_id", unique: true
    t.index ["item_id"], name: "index_low_level_requirements_on_item_id"
    t.index ["model_file_id"], name: "index_low_level_requirements_on_model_file_id"
    t.index ["organization"], name: "index_low_level_requirements_on_organization"
    t.index ["project_id"], name: "index_low_level_requirements_on_project_id"
    t.index ["reqid", "project_id", "item_id", "archive_id"], name: "index_llrs_on_reqid_and_project_id_and_item_id_and_archive_id", unique: true
  end

  create_table "md_scs", id: false, force: :cascade do |t|
    t.integer "module_description_id"
    t.integer "source_code_id"
    t.index ["module_description_id"], name: "index_md_scs_on_module_description_id"
    t.index ["source_code_id"], name: "index_md_scs_on_source_code_id"
  end

  create_table "model_files", force: :cascade do |t|
    t.integer "model_id"
    t.string "full_id"
    t.text "description"
    t.string "file_path"
    t.string "file_type"
    t.string "url_type"
    t.string "url_link"
    t.string "url_description"
    t.boolean "soft_delete"
    t.boolean "derived"
    t.string "derived_justification"
    t.string "system_requirement_associations"
    t.string "high_level_requirement_associations"
    t.string "low_level_requirement_associations"
    t.string "test_case_associations"
    t.integer "version"
    t.string "revision"
    t.string "draft_version"
    t.date "revision_date"
    t.string "organization"
    t.bigint "project_id"
    t.bigint "item_id"
    t.bigint "archive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "upload_date"
    t.index ["archive_id"], name: "index_model_files_on_archive_id"
    t.index ["full_id", "project_id", "item_id", "archive_id"], name: "index_model_files_on_full_id_and_project_and_item_and_archive", unique: true
    t.index ["item_id"], name: "index_model_files_on_item_id"
    t.index ["model_id", "project_id", "item_id", "archive_id"], name: "index_model_files_on_model_and_project_and_item_and_archive", unique: true
    t.index ["project_id"], name: "index_model_files_on_project_id"
  end

  create_table "module_descriptions", force: :cascade do |t|
    t.integer "module_description_number"
    t.string "full_id"
    t.text "description"
    t.string "file_name"
    t.integer "version"
    t.string "revision"
    t.string "draft_revision"
    t.date "revision_date"
    t.text "high_level_requirement_associations"
    t.text "low_level_requirement_associations"
    t.boolean "soft_delete"
    t.integer "project_id"
    t.integer "item_id"
    t.integer "archive_id"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string "encrypted_password", null: false
    t.string "password_archivable_type", null: false
    t.integer "password_archivable_id", null: false
    t.string "password_salt"
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "problem_report_attachments", force: :cascade do |t|
    t.bigint "problem_report_id"
    t.bigint "item_id"
    t.bigint "project_id"
    t.string "link_type"
    t.string "link_description"
    t.string "link_link"
    t.string "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.datetime "upload_date"
    t.index ["archive_id"], name: "index_problem_report_attachments_on_archive_id"
    t.index ["item_id"], name: "index_problem_report_attachments_on_item_id"
    t.index ["organization"], name: "index_problem_report_attachments_on_organization"
    t.index ["problem_report_id"], name: "index_problem_report_attachments_on_problem_report_id"
    t.index ["project_id"], name: "index_problem_report_attachments_on_project_id"
  end

  create_table "problem_report_histories", force: :cascade do |t|
    t.text "action"
    t.string "modifiedby"
    t.string "status"
    t.string "severity_type"
    t.datetime "datemodified"
    t.bigint "project_id"
    t.bigint "problem_report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.index ["archive_id"], name: "index_problem_report_histories_on_archive_id"
    t.index ["organization"], name: "index_problem_report_histories_on_organization"
    t.index ["problem_report_id"], name: "index_problem_report_histories_on_problem_report_id"
    t.index ["project_id"], name: "index_problem_report_histories_on_project_id"
  end

  create_table "problem_reports", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "item_id"
    t.integer "prid"
    t.datetime "dateopened"
    t.string "status"
    t.string "openedby"
    t.string "title"
    t.string "product"
    t.string "criticality"
    t.string "source"
    t.string "discipline_assigned"
    t.string "assignedto"
    t.datetime "target_date"
    t.datetime "close_date"
    t.text "description"
    t.string "problemfoundin"
    t.text "correctiveaction"
    t.string "fixed_in"
    t.string "verification"
    t.text "feedback"
    t.text "notes"
    t.string "meeting_id"
    t.boolean "safetyrelated"
    t.datetime "datemodified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.text "referenced_artifacts"
    t.index ["archive_id"], name: "index_problem_reports_on_archive_id"
    t.index ["item_id"], name: "index_problem_reports_on_item_id"
    t.index ["organization"], name: "index_problem_reports_on_organization"
    t.index ["project_id"], name: "index_problem_reports_on_project_id"
  end

  create_table "project_accesses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.string "access", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.index ["organization"], name: "index_project_accesses_on_organization"
    t.index ["project_id"], name: "index_project_accesses_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_accesses_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_accesses_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.string "description"
    t.string "access"
    t.string "project_managers"
    t.string "configuration_managers"
    t.string "quality_assurance"
    t.string "team_members"
    t.string "airworthiness_reps"
    t.integer "sysreq_count", default: 0
    t.integer "pr_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.string "system_requirements_prefix"
    t.string "high_level_requirements_prefix"
    t.string "low_level_requirements_prefix"
    t.string "source_code_prefix"
    t.string "test_case_prefix"
    t.string "test_procedure_prefix"
    t.string "model_file_prefix"
    t.text "module_description_prefix"
    t.index ["archive_id"], name: "index_projects_on_archive_id"
    t.index ["organization"], name: "index_projects_on_organization"
  end

  create_table "review_attachments", force: :cascade do |t|
    t.bigint "review_id"
    t.bigint "item_id"
    t.bigint "project_id"
    t.string "link_type"
    t.string "link_description"
    t.string "link_link"
    t.string "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.string "attachment_type"
    t.datetime "upload_date"
    t.index ["archive_id"], name: "index_review_attachments_on_archive_id"
    t.index ["item_id"], name: "index_review_attachments_on_item_id"
    t.index ["organization"], name: "index_review_attachments_on_organization"
    t.index ["project_id"], name: "index_review_attachments_on_project_id"
    t.index ["review_id"], name: "index_review_attachments_on_review_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "reviewid"
    t.string "reviewtype"
    t.string "title"
    t.string "evaluators"
    t.date "evaldate"
    t.string "description"
    t.integer "version"
    t.bigint "item_id"
    t.bigint "project_id"
    t.integer "clitem_count", default: 0
    t.integer "ai_count", default: 0
    t.text "attendees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.boolean "checklists_assigned"
    t.text "sign_offs"
    t.string "created_by"
    t.string "problem_reports_addressed"
    t.datetime "upload_date"
    t.string "status"
    t.index ["archive_id"], name: "index_reviews_on_archive_id"
    t.index ["item_id"], name: "index_reviews_on_item_id"
    t.index ["organization"], name: "index_reviews_on_organization"
    t.index ["project_id"], name: "index_reviews_on_project_id"
  end

  create_table "security_questions", force: :cascade do |t|
    t.string "locale", null: false
    t.string "name", null: false
  end

  create_table "source_codes", force: :cascade do |t|
    t.integer "codeid"
    t.text "full_id"
    t.text "file_name"
    t.text "module"
    t.text "function"
    t.boolean "derived"
    t.text "derived_justification"
    t.text "high_level_requirement_associations"
    t.text "low_level_requirement_associations"
    t.text "url_type"
    t.text "url_description"
    t.text "url_link"
    t.integer "version"
    t.bigint "item_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.text "description"
    t.boolean "soft_delete"
    t.string "file_path"
    t.string "content_type"
    t.string "file_type"
    t.string "revision"
    t.string "draft_version"
    t.date "revision_date"
    t.datetime "upload_date"
    t.string "external_version"
    t.string "module_description_associations"
    t.index ["archive_id"], name: "index_source_codes_on_archive_id"
    t.index ["codeid", "project_id", "item_id", "archive_id"], name: "index_source_codes_on_codeid_and_project_id_and_item_id", unique: true
    t.index ["full_id", "project_id", "item_id", "archive_id"], name: "index_source_codes_on_full_id_and_project_id_and_item_id", unique: true
    t.index ["item_id"], name: "index_source_codes_on_item_id"
    t.index ["organization"], name: "index_source_codes_on_organization"
    t.index ["project_id"], name: "index_source_codes_on_project_id"
  end

  create_table "spec_objects", force: :cascade do |t|
    t.string "type"
    t.json "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sysreq_hlrs", id: false, force: :cascade do |t|
    t.integer "system_requirement_id"
    t.integer "high_level_requirement_id"
    t.index ["high_level_requirement_id"], name: "index_sysreq_hlrs_on_high_level_requirement_id"
    t.index ["system_requirement_id"], name: "index_sysreq_hlrs_on_system_requirement_id"
  end

  create_table "sysreq_mfs", id: false, force: :cascade do |t|
    t.bigint "system_requirement_id", null: false
    t.bigint "model_file_id", null: false
    t.index ["model_file_id", "system_requirement_id"], name: "index_sysreq_mfs_on_model_file_id_and_system_requirement_id"
    t.index ["system_requirement_id", "model_file_id"], name: "index_sysreq_mfs_on_system_requirement_id_and_model_file_id"
  end

  create_table "system_requirements", force: :cascade do |t|
    t.integer "reqid", null: false
    t.text "full_id"
    t.text "description"
    t.text "category"
    t.text "verification_method"
    t.string "source"
    t.boolean "safety"
    t.string "implementation"
    t.integer "version"
    t.boolean "derived"
    t.text "derived_justification"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.boolean "soft_delete"
    t.bigint "document_id"
    t.bigint "model_file_id"
    t.index ["archive_id"], name: "index_system_requirements_on_archive_id"
    t.index ["document_id"], name: "index_system_requirements_on_document_id"
    t.index ["full_id", "project_id", "archive_id"], name: "index_sysreq__on_fullid_and_project_id_and_archive_id", unique: true
    t.index ["model_file_id"], name: "index_system_requirements_on_model_file_id"
    t.index ["organization"], name: "index_system_requirements_on_organization"
    t.index ["project_id"], name: "index_system_requirements_on_project_id"
    t.index ["reqid", "project_id", "archive_id"], name: "index_sysreq__on_reqid_and_project_id_and_archive_id", unique: true
  end

  create_table "tc_mfs", id: false, force: :cascade do |t|
    t.bigint "test_case_id", null: false
    t.bigint "model_file_id", null: false
    t.index ["model_file_id", "test_case_id"], name: "index_tc_mfs_on_model_file_id_and_test_case_id"
    t.index ["test_case_id", "model_file_id"], name: "index_tc_mfs_on_test_case_id_and_model_file_id"
  end

  create_table "tcs_tps", id: false, force: :cascade do |t|
    t.integer "test_case_id"
    t.integer "test_procedure_id"
    t.index ["test_case_id"], name: "index_tcs_tps_on_test_case_id"
    t.index ["test_procedure_id"], name: "index_tcs_tps_on_test_procedure_id"
  end

  create_table "template_checklist_items", force: :cascade do |t|
    t.integer "clitemid"
    t.text "title"
    t.text "description"
    t.text "note"
    t.bigint "template_checklist_id"
    t.string "reference"
    t.string "minimumdal"
    t.text "supplements"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.string "version"
    t.string "source"
    t.index ["organization"], name: "index_template_checklist_items_on_organization"
    t.index ["template_checklist_id"], name: "index_template_checklist_items_on_template_checklist_id"
  end

  create_table "template_checklists", force: :cascade do |t|
    t.integer "clid"
    t.text "title"
    t.text "description"
    t.text "notes"
    t.text "checklist_class"
    t.text "checklist_type"
    t.bigint "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.string "version"
    t.string "source"
    t.string "filename"
    t.string "revision"
    t.string "draft_revision"
    t.index ["organization"], name: "index_template_checklists_on_organization"
    t.index ["template_id"], name: "index_template_checklists_on_template_id"
  end

  create_table "template_documents", force: :cascade do |t|
    t.integer "document_id"
    t.text "title"
    t.text "description"
    t.text "notes"
    t.string "docid"
    t.text "name"
    t.string "category"
    t.string "document_type"
    t.text "document_class"
    t.string "file_type"
    t.bigint "template_id"
    t.string "organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dal"
    t.string "version"
    t.string "source"
    t.string "revision"
    t.string "draft_revision"
    t.datetime "upload_date"
    t.string "filename"
    t.index ["template_id"], name: "index_template_documents_on_template_id"
  end

  create_table "templates", force: :cascade do |t|
    t.integer "tlid"
    t.text "title"
    t.text "description"
    t.text "notes"
    t.text "template_class"
    t.text "template_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.string "version"
    t.string "source"
    t.index ["organization"], name: "index_templates_on_organization"
  end

  create_table "test_cases", force: :cascade do |t|
    t.integer "caseid"
    t.text "full_id"
    t.text "description"
    t.text "procedure"
    t.string "category"
    t.boolean "robustness"
    t.boolean "derived"
    t.string "testmethod"
    t.integer "version"
    t.bigint "item_id"
    t.bigint "project_id"
    t.text "high_level_requirement_associations"
    t.text "low_level_requirement_associations"
    t.text "derived_justification"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organization"
    t.bigint "archive_id"
    t.text "test_procedure_associations"
    t.boolean "soft_delete"
    t.bigint "document_id"
    t.bigint "model_file_id"
    t.index ["archive_id"], name: "index_test_cases_on_archive_id"
    t.index ["caseid", "project_id", "item_id", "archive_id"], name: "index_test_cases_caseid_project_id_item_id_archive_id", unique: true
    t.index ["document_id"], name: "index_test_cases_on_document_id"
    t.index ["full_id", "project_id", "item_id", "archive_id"], name: "index_test_cases_full_id_project_id_item_id_archive_id", unique: true
    t.index ["item_id"], name: "index_test_cases_on_item_id"
    t.index ["model_file_id"], name: "index_test_cases_on_model_file_id"
    t.index ["organization"], name: "index_test_cases_on_organization"
    t.index ["project_id"], name: "index_test_cases_on_project_id"
  end

  create_table "test_procedures", force: :cascade do |t|
    t.integer "procedure_id"
    t.text "full_id"
    t.text "file_name"
    t.text "test_case_associations"
    t.text "url_type"
    t.text "url_description"
    t.text "url_link"
    t.integer "version"
    t.string "organization"
    t.bigint "item_id"
    t.bigint "project_id"
    t.bigint "archive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.boolean "soft_delete"
    t.bigint "document_id"
    t.string "file_path"
    t.string "content_type"
    t.string "file_type"
    t.string "revision"
    t.string "draft_version"
    t.date "revision_date"
    t.datetime "upload_date"
    t.index ["archive_id"], name: "index_test_procedures_on_archive_id"
    t.index ["document_id"], name: "index_test_procedures_on_document_id"
    t.index ["full_id", "project_id", "item_id", "archive_id"], name: "index_test_procedures_on_full_id_and_project_id_and_item_id", unique: true
    t.index ["item_id"], name: "index_test_procedures_on_item_id"
    t.index ["organization"], name: "index_test_procedures_on_organization"
    t.index ["procedure_id", "project_id", "item_id", "archive_id"], name: "index_test_procedures_on_procedure_id_and_project_id_and_item", unique: true
    t.index ["project_id"], name: "index_test_procedures_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.text "role", null: false
    t.boolean "fulladmin", default: false
    t.boolean "notify_on_changes", default: false
    t.boolean "password_reset_required", default: false
    t.boolean "user_disabled", default: false
    t.string "time_zone", default: "Pacific Time (US & Canada)"
    t.text "organization"
    t.text "title"
    t.text "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.boolean "user_enabled"
    t.string "organizations"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "password_changed_at"
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.string "unique_session_id"
    t.integer "security_question_id"
    t.string "security_question_answer"
    t.string "otp_secret_key"
    t.string "use_multifactor_authentication"
    t.string "login_state"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["expired_at"], name: "index_users_on_expired_at"
    t.index ["last_activity_at"], name: "index_users_on_last_activity_at"
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "action_items", "items"
  add_foreign_key "action_items", "projects"
  add_foreign_key "action_items", "reviews"
  add_foreign_key "change_sessions", "data_changes"
  add_foreign_key "checklist_items", "documents"
  add_foreign_key "checklist_items", "reviews"
  add_foreign_key "code_checkmark_hits", "code_checkmarks"
  add_foreign_key "code_checkmarks", "source_codes"
  add_foreign_key "code_conditional_blocks", "source_codes"
  add_foreign_key "document_attachments", "documents"
  add_foreign_key "document_attachments", "items"
  add_foreign_key "document_attachments", "projects"
  add_foreign_key "document_comments", "documents"
  add_foreign_key "document_comments", "items"
  add_foreign_key "document_comments", "projects"
  add_foreign_key "documents", "items"
  add_foreign_key "documents", "projects"
  add_foreign_key "documents", "reviews"
  add_foreign_key "github_accesses", "users"
  add_foreign_key "gitlab_accesses", "users"
  add_foreign_key "high_level_requirements", "documents"
  add_foreign_key "high_level_requirements", "items"
  add_foreign_key "high_level_requirements", "model_files"
  add_foreign_key "high_level_requirements", "projects"
  add_foreign_key "items", "projects"
  add_foreign_key "low_level_requirements", "documents"
  add_foreign_key "low_level_requirements", "items"
  add_foreign_key "low_level_requirements", "model_files"
  add_foreign_key "low_level_requirements", "projects"
  add_foreign_key "model_files", "archives"
  add_foreign_key "model_files", "items"
  add_foreign_key "model_files", "projects"
  add_foreign_key "problem_report_attachments", "items"
  add_foreign_key "problem_report_attachments", "problem_reports"
  add_foreign_key "problem_report_attachments", "projects"
  add_foreign_key "problem_report_histories", "problem_reports"
  add_foreign_key "problem_report_histories", "projects"
  add_foreign_key "problem_reports", "items"
  add_foreign_key "problem_reports", "projects"
  add_foreign_key "project_accesses", "projects"
  add_foreign_key "project_accesses", "users"
  add_foreign_key "review_attachments", "items"
  add_foreign_key "review_attachments", "projects"
  add_foreign_key "review_attachments", "reviews"
  add_foreign_key "reviews", "items"
  add_foreign_key "reviews", "projects"
  add_foreign_key "source_codes", "items"
  add_foreign_key "source_codes", "projects"
  add_foreign_key "system_requirements", "documents"
  add_foreign_key "system_requirements", "model_files"
  add_foreign_key "system_requirements", "projects"
  add_foreign_key "template_checklist_items", "template_checklists"
  add_foreign_key "template_checklists", "templates"
  add_foreign_key "template_documents", "templates"
  add_foreign_key "test_cases", "documents"
  add_foreign_key "test_cases", "items"
  add_foreign_key "test_cases", "model_files"
  add_foreign_key "test_cases", "projects"
  add_foreign_key "test_procedures", "archives"
  add_foreign_key "test_procedures", "documents"
  add_foreign_key "test_procedures", "items"
  add_foreign_key "test_procedures", "projects"
end
