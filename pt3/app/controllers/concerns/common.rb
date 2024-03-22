module Common
  extend ActiveSupport::Concern

  ### Users ###
  # Get the user from the userid.
  def get_user(userid)
    @user = User.find_by(id: userid)
  end
  # Get all users.
  def get_users
    @users = User.all
  end
  # Return current user if available.
  def get_current_user
    if current_user then
      return current_user
    else
      return nil
    end
  end

  # Return current project if available.
  def get_current_project
    return Project.current
  end

  ### Projects ###
  # Get the project for the parameter provided id.
  def get_project_fromitemid
    get_item
    get_project(@item.project_id) if @item.present?
  end
  # Get project from the id
  def get_project(project_id)
    @project = Project.find_by(id: project_id)
    set_current_project(@project)
  end
  # Get the project for the parameter provided id.
  def get_project_byparam
    @project = Project.find_by(id: params[:project_id])
    set_current_project(@project)
  end

  # Get all projects.
  def get_projects
    @projects = Project.all
  end

  ### Items ###
  # Get the items for the parameter provided id.
  def get_item
    @item = Item.find_by(id: params[:item_id]) if params[:item_id].present?
  end

  # Get all items.
  def get_items
    @items = Item.all
  end

  ### System Requirements ###
  # Get system requirements for selected project
  def get_system_requirements(*args)
    options    = args.extract_options!
    item_id    = options[:item_id] || params[:item_id] || nil
    project_id = options[:project_id] || params[:project_id] || nil

    if session[:archives_visible]
      if item_id != nil
          system_requirements = SystemRequirement.where(project_id:   Project.find_by(id: Item.find_by(id: item_id).project_id),
                                                        organization: current_user.organization)
      elsif project_id != nil
          system_requirements = SystemRequirement.where(project_id:   project_id,
                                                        organization: current_user.organization)
      else
        system_requirements = nil
      end
    else
      if item_id != nil
          system_requirements = SystemRequirement.where(project_id:   Project.find_by(id: Item.find_by(id: item_id).project_id),
                                                        organization: current_user.organization,
                                                        archive_id:  nil)
      elsif project_id != nil
          system_requirements = SystemRequirement.where(project_id:   project_id,
                                                        organization: current_user.organization,
                                                        archive_id:  nil)
      else
        system_requirements = nil
      end
    end
    return sort_on_full_id(system_requirements)
  end

  def sort_on_full_id(items)
    items.sort() do |x, y|
      x_id = ''
      y_id = ''

      if x.full_id =~ /^.*\-(\d+)$/
        x_id = Regexp.last_match[1].to_i
      else
        x_id = x.full_id
      end

      if y.full_id =~ /^.*\-(\d+)$/
        y_id = Regexp.last_match[1].to_i
      else
        y_id = y.full_id
      end

      if x_id.present? && y_id.present?
        if x_id.class.name ==  y_id.class.name
          x_id <=> y_id
        else
          x_id.to_s <=> y_id.to_s
        end
      else
        0
      end
    end
  end

  ### Counters ###
  # Increment an integer
  def increment_int(int)
    # Check if numeric
    if int.is_a? Numeric
      int_y = int + 1
    else
      int_y = 1
    end
    return int_y
  end

  # Decrement an integer
  def decrement_int(int)
    # Check if numeric
    if int.is_a? Numeric
      int_y = int - 1
    else
      int_y = 1
    end
    # If less than 0, make it 0.
    if int_y < 0
      int_y = 0
    end
    return int_y
  end

  def increment_draft_revision(draft_revision)
    if draft_revision.kind_of?(String)
      if draft_revision =~ /^\d+$/
        draft_revision  = draft_revision.to_i
        draft_revision += 1
        draft_revision  = sprintf('%0.1f', draft_revision.to_s)
      elsif draft_revision =~ /^\d*\.{0,1}\d+$/
        draft_revision  = draft_revision.to_f
        draft_revision += 0.1
        draft_revision  = sprintf('%0.1f', draft_revision.to_s)
      end
    elsif draft_revision.kind_of?(Integer)
      draft_revision += 1
    elsif draft_revision.kind_of?(Float)
      draft_revision += 0.1
    end

    return draft_revision
  end

  def alpha_to_digit(character)
    result = nil

    return result unless character =~ /^[a-z]$/i

    if (character =~ /^[A-Z]$/)
      result = (character.ord - 'A'.ord)
    else
      result = (character.ord - 'a'.ord)
    end

    return result
  end

  def digit_to_alpha(digit, uppercase = false)
    result = nil

    return result unless digit.kind_of?(Integer)
    return result if ((digit < 0) || (digit > 25))

    result = if uppercase
               ('A'.ord + digit).chr
             else
               ('a'.ord + digit).chr
             end

    return result
  end

  def increment_alpha_revision(alpha_revision)
    # This only deals with a string that is all of the same case
    # Since this is for revisions we limit the string from 'A' to 'ZZ'
    # the assumption is that there will not be more than 675 revisions

    return alpha_revision unless alpha_revision =~ /^[a-z]+$/i

    uppercase             = (alpha_revision[0] =~ /^[A-Z]$/)

    if alpha_revision =~ /^[a-z]$/i
      alpha_revision      = alpha_to_digit(alpha_revision)
      alpha_revision     += 1;

      if alpha_revision <= 25
        alpha_revision    = digit_to_alpha(alpha_revision, uppercase)
      else
        alpha_revision    = if uppercase
                              'AA'
                            else
                              'aa'
                            end
      end
    elsif alpha_revision =~ /^[a-z][a-z]$/i
      digits              = []
      digits[0]           = alpha_to_digit(alpha_revision[0])
      digits[1]           = alpha_to_digit(alpha_revision[1])
      alpha_revision      = (digits[0] * 26) + digits[1]
      alpha_revision     += 1;

      if alpha_revision > 675
        alpha_revision    = if uppercase
                              'AAA'
                            else
                              'aaa'
                            end
      else
        alpha_revision    = digit_to_alpha((alpha_revision / 26), uppercase) +
                            digit_to_alpha((alpha_revision % 26), uppercase)
      end
    end

    return alpha_revision
  end

  # Increment a Draft Revision
  def increment_revision(revision)
    if revision.kind_of?(String)
      revision = increment_alpha_revision(revision) if revision =~ /^[a-z]+$/i
    elsif revision.kind_of?(Integer)
      revision += 1
    elsif revision.kind_of?(Float)
      revision += 0.1
    end

    return revision
  end

  def get_last_data_change(table_name)
    @undo_data_change = DataChange.where(changed_by: current_user.email, table_name: table_name, change_type: Constants::UNDO, organization: current_user.organization).order('performed_at ASC').last
    @undo_message     = "Undo #{@undo_data_change.get_description}" if @undo_data_change.present?
  end

  def get_last_change_session(table_name)
    get_last_data_change(table_name)

    if @undo_data_change.present?
      ChangeSession.find_by(data_change_id: @undo_data_change.id, organization: current_user.organization)
    else
      nil
    end
  end

  def get_undo_path(table_name, success_path)
    last_change_session = get_last_change_session(table_name)

    if last_change_session.present?
      "#{change_session_undo_url(last_change_session.session_id)}?success_path=#{success_path}"
    else
      nil
    end
  end

  def get_last_redo_data_change(table_name)
    @redo_data_change = DataChange.where(changed_by: current_user.email, table_name: table_name, change_type: Constants::REDO, organization: current_user.organization).order('performed_at ASC').last
    @redo_message     = "Redo #{@redo_data_change.get_description}" if @redo_data_change.present?
  end

  def get_last_redo_change_session(table_name)
    get_last_redo_data_change(table_name)

    if @redo_data_change.present?
      ChangeSession.find_by(data_change_id: @redo_data_change.id, organization: current_user.organization)
    else
      nil
    end
  end

  def get_redo_path(table_name, success_path)
    last_change_session = get_last_redo_change_session(table_name)

    if last_change_session.present?
      "#{change_session_redo_url(last_change_session.session_id)}?success_path=#{success_path}"
    else
      nil
    end
  end

  def get_model_file_list(project_id, item_id = nil)
    file_types      = [
                         'image/x-png',
                         'image/png',
                         'image/gif',
                         'image/jpeg',
                         'image/tiff',
                         nil
                      ]
    file_extensions = [
                         'png',
                         'gif',
                         'jpeg',
                         'tiff',
                         nil
                      ]
    result          = if action_name == 'edit'
                        [
                          [
                             Constants::REPLACE_FILE,
                             -1
                          ]
                        ]
                      else
                        [
                          [
                             Constants::UPLOAD_FILE,
                             -1
                          ]
                        ]
                      end
    model_files     = if item_id.present?
                        ModelFile.where(item_id: item_id, archive_id: nil)
                      else
                        ModelFile.where(project_id: project_id, archive_id: nil)
                      end

    model_files.each do |model_file|
      next if model_file.archive_id.present?             ||
              !file_types.include?(model_file.file_type) ||
              (model_file.file_path =~ /^.+\.(.+)$/      &&
               !file_extensions.include?($1))

      file          = [
                        Sanitize.fragment(model_file.description).gsub('&nbsp;', ' ').strip,
                        model_file.id
                      ]

      result.push(file)
    end

    return result
  end

  def get_pact_files(item_id      = nil,
                     project_id   = nil,
                     review_id    = nil,
                     organization = current_user.organization)
    pact_files = []
    item_id    = @item.id    if !item_id.present?    && @item.present?
    project_id = @project.id if !project_id.present? && @project.present?
    documents  = if review_id.present?
                   Document.where(review_id: review_id).order(:name)
                 elsif item_id.present?
                   Document.where(item_id: item_id).order(:name)
                 elsif project_id.present?
                   Document.where(project_id: project_id).order(:name)
                 elsif organization.present?
                   Document.where(organization: organization).order(:name)
                 end

    documents.each do |document|
      next if document.document_type == Constants::FOLDER_TYPE || document.archive_id.present?

      file     = [
                    document.name,
                    item_document_path(document.item_id, document)
                 ]

      pact_files.push(file)
    end if documents.present?

    return pact_files
  end

  def set_session
    RequirementsTracing.session = session
  end

  def fix_sequence(sequence_name)
    result          = false
    current_value   = nil

    return result unless sequence_name.present?

    sequence_class  = controller_name.classify.constantize
    max_id          = sequence_class.all.maximum(:id)

    ActiveRecord::Base.transaction do
      current_value = sequence_class.connection.select_value("select nextval('#{sequence_class.sequence_name}')").to_i

      raise ActiveRecord::Rollback
    end

    if current_value.present? && max_id.present? && (current_value < max_id)
      ActiveRecord::Base.connection.execute("SELECT setval('#{sequence_name}', #{max_id + 1})")

      result        = true
    end

    return result
  end
end
