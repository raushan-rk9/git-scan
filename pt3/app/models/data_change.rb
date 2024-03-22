class DataChange < OrganizationRecord
  belongs_to :change_session, optional: true

  # Validations
  validates  :changed_by,     presence: true, allow_blank: false
  validates  :table_name,     presence: true, allow_blank: false
  validates  :table_id,       numericality: { only_integer: true }
  validates  :action,         presence: true, allow_blank: false
  validates  :performed_at,   presence: true

  # Method:      get_record_id
  # Parameters:  None.
  #
  # Return:      A string, the record id
  # Description: Returns a record id for the record.
  # Calls:       
  # Notes:       
  # History:     05-07-2020 - First Written, PC

  def get_record_id
    result   = ''

    if record_attributes['full_id'].present?
      result = record_attributes['full_id']
    elsif record_attributes['name'].present?
      result = record_attributes['name']
    elsif record_attributes['title'].present?
      result = record_attributes['title']
    elsif record_attributes['description'].present?
      result = record_attributes['description']
    else
      result = record_attributes['id']
    end

    result = Sanitize.fragment(result).gsub(/&.+;/, '') if result.present?

    return result
  end

  # Method:      get_table_name
  # Parameters:  None.
  #
  # Return:      A string, the table name
  # Description: Returns a table name for the record.
  # Calls:       
  # Notes:       
  # History:     05-07-2020 - First Written, PC

  def get_table_name
    result = table_name.gsub('_', ' ').titleize

    return result
  end

  # Method:      get_description
  # Parameters:  None.
  #
  # Return:      A string, the description
  # Description: Returns a table name for the record.
  # Calls:       
  # Notes:       
  # History:     05-07-2020 - First Written, PC

  def get_description
    result = "#{action.titleize} Record: #{get_record_id} in #{get_table_name}"

    return result
  end

  # Method:      redo
  # Parameters:  None.
  #
  # Return:      True if successful or false if there was an error.
  # Description: This redos changes to the object.
  # Calls:       
  # Notes:       This method raises errors.
  # History:     05-06-2020 - First Written, PC

  def redo
    result              = false
    object              = nil

    return result unless change_type == Constants::REDO
    return result unless self.table_id.present? || (action == 'create' )

    Associations.clear_associations(table_id, table_name) if (action != 'create' )

    case(action)
      when 'create'
        object          = table_name.singularize.classify.constantize.new

        if object.present?
          attributes    = record_attributes

          attributes.each do |key, value|
            object[key] = value
          end

          object.save! if action != 'store'

          self.table_id = object.id
          result        = true
        end

      when 'update'
        object          = table_name.singularize.classify.constantize.find_by(id: self.table_id)

        if object.present?
          attributes    = record_attributes

          attributes.each do |key, value|
            object[key] = value
          end

          object.save!

          result        = true
        end

      when 'delete'
        if table_name.singularize.classify.constantize.find_by(id: self.table_id)
          table_name.singularize.classify.constantize.destroy(self.table_id)

          result        = true
        end
    end

    Associations.build_associations(object) if result

    return result
  end

  # Method:      undo
  # Parameters:  None.
  #
  # Return:      True if successful or false if there was an error.
  # Description: This undoes changes to the object.
  # Calls:       
  # Notes:       This method raises errors.
  # History:     06-24-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def undo
    result            = false
    object            = nil

    return result unless change_type == Constants::UNDO
    return result unless self.table_id.present? || (action == 'delete' )

    Associations.clear_associations(table_id, table_name) if action != 'delete'

    if action == 'create'
      if table_name.singularize.classify.constantize.find_by(id: self.table_id)
        table_name.singularize.classify.constantize.destroy(self.table_id) 

        result        = true
      else
        return false
      end
    else
      object          = if action == 'delete'
                          table_name.singularize.classify.constantize.new
                        else
                          table_name.singularize.classify.constantize.find_by(id: self.table_id)
                        end

      if object.present?
        attributes    = record_attributes

        attributes.each do |key, value|
          object[key] = value
        end

        object.save! if action != 'store'
      end
    end

    Associations.build_associations(object) if result

    return result
  end

  # Method:      save_or_destroy_with_undo_session
  # Parameters:  active_record_object the Active Record Object to save or delete.
  #
  #              action a string the action that is being performed:
  #              'create', 'update', 'delete' or 'store'.
  #
  #              session_id an integer (default nil) if nil it creates a new
  #              session otherwise it adds it to the session.
  #
  # Return:      A ChangeSession object containing the change_session or
  #              nil if there was an error.
  # Description: This method replaces save! or destroy it records the changes
  #              so they can be undone.
  # Calls:       save_or_destroy_with_undo and
  #              ChangeSession.start_new_change_session or
  #              ChangeSession.add_change_session
  # Notes:       This method saves or destroys the object.
  #              This method raises errors.
  # History:     06-24-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.save_or_destroy_with_undo_session(active_record_object,
                                             action,
                                             id          = nil,
                                             table_name  = nil,
                                             session_id  = nil,
                                             change_type = Constants::UNDO)
    result        = nil
    change_object = save_or_destroy_with_undo(active_record_object, action, id,
                                              table_name, change_type)
    result        = if session_id.present?
                      ChangeSession.add_change_session(session_id,
                                                       change_object.id)
                    else
                      ChangeSession.start_new_change_session(change_object.id)
    end

    return result
  end
  
  # Method:      save_or_destroy_with_undo
  # Parameters:  active_record_object the Active Record Object to save or delete.
  #
  #              action a string the action that is being performed:
  #              'create', 'update', 'delete' or 'store'.
  #
  # Return:      A new DataChange object containing the changes
  #              or nil if there was an error.
  # Description: This method replaces save! or destroy it records the changes
  #              so they can be undone.
  # Calls:       record_change and ActiveRecord.save! or ActiveRecord.destroy
  # Notes:       This method saves or destroys the object.
  #              This method raises errors.
  # History:     06-24-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.save_or_destroy_with_undo(active_record_object,
                                     action,
                                     id          = nil,
                                     table_name  = nil,
                                     change_type = Constants::UNDO)
    result                     = nil

    if active_record_object.present? && VALID_ACTIONS.include?(action)
      if active_record_object.kind_of?(Hash) ||
         active_record_object.kind_of?(ActionController::Parameters) # This is a Hash we need to convert it to an active record object
        if active_record_object['id'].present? || id.present?
          record               = if id.present?
                                   table_name.classify.constantize.find(id)
                                 else
                                   table_name.classify.constantize.find(active_record_object['id'])
                                 end

          active_record_object.each do |key, value|
            record[key]        = value if table_name.classify.constantize.column_names.include?(key)
          end

          active_record_object = record
        else
          active_record_object = table_name.classify.constantize.new(active_record_object)
        end
      else
        table_name             = active_record_object.class.table_name
      end

      if action == 'create' # We don't need to save the data the undo is to simply destroy it
        active_record_object.save!

        result                 = self.record_change(table_name,
                                                    action,
                                                    active_record_object.id,
                                                    active_record_object,
                                                    change_type)

        if result
          result.table_id      = active_record_object.id

          result.save!
        end
      elsif active_record_object.id.kind_of?(Integer) # we need to save the old data before we save the object
        old_object             = active_record_object.class.find(active_record_object.id)

        if action != 'store'
          if action == 'delete'
            active_record_object.destroy
          else
            active_record_object.save!
          end
        end

        result                 = self.record_change(table_name,
                                                    action,
                                                    active_record_object.id,
                                                    old_object,
                                                    change_type)

        result.save! if result
      end
    end

    return result
  end

  # Method:      record_change
  # Parameters:  table_name a string the name of the table that is being changed,
  #              see VALID_TABLES (below) for a list of tables.
  #
  #              action a string the action this is being performed: 'Create',
  #              'update', 'delete' or 'store'.
  #
  #              table_id a integer, the id of the table for a 'update' or 'delete'
  #
  #              active_record_object an optional Active Record Oject (default: nil),
  #              The record of the object that is being changed.
  #
  # Return:      A new DataChange Object containing the changes.
  # Description: This creates a new DataChange object
  # Calls:       
  # Notes:       
  # History:     06-21-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.record_change(table_name, action, table_id, active_record_object,
                         change_type = Constants::UNDO)
    result = nil

    if table_name.present?               &&
       VALID_TABLES.include?(table_name) &&
       action.present?                   &&
       VALID_ACTIONS.include?(action)    &&
       (table_id.kind_of?(Integer)       || (action == 'create'))
          current_user                  = User.current
          data_change                   = DataChange.new()
          data_change.changed_by        = if ((defined? current_user) && current_user.email.present?)
                                            current_user.email
                                          else
                                            'Unknown'
                                          end
          data_change.table_name        = table_name
          data_change.table_id          = table_id
          data_change.action            = action
          data_change.change_type       = change_type
          data_change.record_attributes = active_record_object.attributes if active_record_object.present?                  &&
                                                                             active_record_object.attributes.kind_of?(Hash) &&
                                                                             !active_record_object.attributes.empty?
          data_change.performed_at      = DateTime.now.utc
          result                        = data_change
    end

    return result
  end

  # Method:      store
  # Parameters:  table_name a string the name of the table that is being stored,
  #              see VALID_TABLES (below) for a list of tables.
  #
  #              table_id a integer, the id of the object.
  #
  #              active_record_object an optional Active Record Oject (default: nil),
  #              The record of the object that is being changed.
  #
  # Return:      A new DataChange Object containing the changes.
  # Description: This creates a new DataChange object
  # Calls:       self.save_or_destroy_with_undo
  # Notes:       
  # History:     08-17-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.store(table_name,
                 table_id,
                 active_record_object,
                 session_id  = nil,
                 change_type = Constants::UNDO)
    self.save_or_destroy_with_undo(active_record_object,
                                   'store', 
                                   table_id,
                                   table_name,
                                   session_id,
                                   change_type)
  end

  # Method:      retrieve
  # Parameters:  table_name a string the name of the table for the object that is being retrieved,
  #              see VALID_TABLES (below) for a list of tables.
  #
  #              table_id a integer, the id of the object
  #
  # Return:      The object that was stored.
  # Description: This retires a stored  DataChange object
  # Calls:       undo
  # Notes:       
  # History:     08-17-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.retrieve(table_name, table_id, change_type = Constants::UNDO)
    data_change   = DataChange.find_all_by(id: table_id, table_name: table_name, change_type: change_type, action: 'store').last

    return nil unless data_change.present?

    result        = table_name.singularize.classify.constantize.find_by(id: table_id)

    return result unless result.present?

    attributes    = record_attributes

    attributes.each do |key, value|
      result[key] = value
    end

    data_change.destroy

    return result
  end

  # Method:      find_or_retrieve
  # Parameters:  table_name a string the name of the table for the object that is being found or retrieved,
  #              see VALID_TABLES (below) for a list of tables.
  #
  #              table_id a integer, the id of the object
  #
  # Return:      The object that was stored or found.
  # Description: This retrieves a stored DataChange object and if there is not one it does a find for the object.
  # Calls:       retrieve
  # Notes:       Throws errors
  # History:     08-19-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.find_or_retrieve(table_name, table_id, change_type = Constants::UNDO)
    result   = retrieve(table_name, table_id, change_type)

    unless result.present?
      result = table_name.singularize.classify.constantize.find(table_id)
    end

    return result
  end

  # Method:      clear_undo_history
  # Parameters:  None.
  #
  # Return:      Non.e
  # Description: This clears out undo history for the current user
  # Calls:       
  # Notes:       Throws Errors
  # History:     05-07-2020 - First Written, PC

  def self.clear_undo_history
    data_changes     = DataChange.where(changed_by: User.current.email) if User.current.present?

    data_changes.each do |data_change|
      change_session = ChangeSession.find_by(data_change_id: data_change.id)

      change_session.destroy if change_session.present?
      data_change.destroy
    end if data_changes.present?
  end

private
  VALID_TABLES =  [
                    'action_items', 'checklist_items', 'documents',
                    'document_attachments', 'document_comments',
                    'high_level_requirements', 'items', 'low_level_requirements',
                    'problem_reports', 'problem_report_attachments',
                    'problem_report_histories', 'projects', 'reviews',
                    'review_attachments', 'system_requirements', 'test_cases',
                    "sysreq_hlrs", "hlr_llrs", "hlr_tcss", "source_codes",
                    "github_accesses", "gitlab_accesses", "templates",
                    "template_checklists", "template_checklist_items",
                    "project_accesses", "archives", "template_documents",
                    "code_checkmarks", "code_checkmark_hits",
                    "code_conditional_blocks", "test_procedures",
                    "document_types", "licensees", "model_files",
                    "function_items", "module_descriptions"
                  ]

  VALID_ACTIONS = [ 'create', 'update', 'delete', 'store' ]
end
