class ChangeSession < OrganizationRecord
  has_many  :data_changes

  # Validations
  validates :session_id,     numericality: { only_integer: true }
  validates :data_change_id, numericality: { only_integer: true }

  # Method:      redo
  # Parameters:  session_id an integer the session to redo
  #
  # Return:      True if the session was successfully redone fale if there was an error.
  # Description: Rolls back a session
  # Calls:       redo for a DataChange Record
  #              
  # Notes:       
  # History:     05-06-2020 - First Written, PC

  def self.redo(session_id)
    result          = false

    return result unless session_id.present?

    change_sessions = ChangeSession.where(session_id:   session_id,
                                          organization: User.current.organization)

    ActiveRecord::Base.transaction do
      change_sessions.each do |session|
        data_change = DataChange.find(session.data_change_id)

        next if data_change.change_type == Constants::UNDO

        data_change.redo
        session.destroy
        data_change.destroy
      end

      result = true
    end

    return result
  end

  # Method:      setup_redo_record
  # Parameters:  data_change a DataChange object, the undo to setup a redo for.
  #
  # Return:      The redo DataChange record or nil if there was an error.
  # Description: Sets up a redo record
  # Calls:       
  #              
  # Notes:       
  # History:     05-07-2020 - First Written, PC

  def self.setup_redo_record(data_change)
    result             = nil

    return result unless data_change.present?

    result             = data_change.dup
    result.change_type = Constants::REDO

    if data_change.action == 'update'
      object                   = data_change.table_name.singularize.classify.
                                 constantize.find_by(id: data_change.table_id)
      result.record_attributes = object.attributes if object.present?                  &&
                                                      object.attributes.kind_of?(Hash) &&
                                                      !object.attributes.empty?
    end

    return result
  end

  # Method:      undo
  # Parameters:  session_id an integer the session to undo
  #
  # Return:      True if the session was successfully undone fale if there was an error.
  # Description: Rolls back a session
  # Calls:       undo for a DataChange Record
  #              
  # Notes:       
  # History:     06-24-2019 - First Written, PC
  #              05-06-2020 - Redo added, PC

  def self.undo(session_id)
    result                     = false

    return result unless session_id.present?

    change_sessions            = ChangeSession.where(session_id:   session_id,
                                                     organization: User.current.organization)

    ActiveRecord::Base.transaction do
      change_sessions.each do |session|
        data_change             = DataChange.find(session.data_change_id)

        next if data_change.change_type == Constants::REDO

        redo_record            = self.setup_redo_record(data_change)

        data_change.undo
        redo_record.save!

        session.data_change_id = redo_record.id

        session.save!

        data_change.destroy
      end

      result                   = true
    end

    return result
  end

  # Method:      get_session_id
  # Parameters:  None.
  #
  # Return:      A new session ID.
  # Description: This gets a new session id
  # Calls:       
  # Notes:       
  # History:     05-18-2020 - First Written, PC

  def self.get_session_id
    result     = nil
    pg_results = ActiveRecord::Base.connection.execute("SELECT nextval('session_id_seq')")

    pg_results.each { |row| result = row["nextval"] } if pg_results.present?

    return result
  end

  # Method:      start_new_change_session
  # Parameters:  data_change_id an integer, the change id of the object that was changed.
  #
  # Return:      A new ChangeSession Object containing the changes.
  # Description: This creates a new ChangeSession object with a new session id
  # Calls:       
  # Notes:       
  # History:     06-21-2019 - First Written, PC

  def self.start_new_change_session(data_change_id)
    result                = ChangeSession.new()
    session_id            = get_session_id
    result.session_id     = session_id
    result.data_change_id = data_change_id

    result.save!

    return result
  end

  # Method:      add_change_session
  # Parameters:  session_id an integer, the session of the object that was changed.
  #              data_change_id an integer, the id of the object that was changed.
  #
  # Return:      A new ChangeSession Object containing the changes.
  # Description: This creates a new ChangeSession object with an existing session id.
  # Calls:       
  # Notes:       
  # History:     06-24-2019 - First Written, PC

  def self.add_change_session(session_id, data_change_id)
    result                 = ChangeSession.new()
    result.session_id      = session_id
    result.data_change_id  = data_change_id

    result.save!

    return result
  end
end
