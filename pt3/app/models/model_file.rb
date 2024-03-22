class ModelFile < OrganizationRecord
  belongs_to              :project
  belongs_to              :item,     optional: true
  belongs_to              :archive,  optional: true

  # Associate Model Files with System Requirements
  has_and_belongs_to_many :system_requirements,     -> { distinct }, join_table: 'sysreq_mfs'

  # Associate Model Files with High-Level Requirements
  has_and_belongs_to_many :high_level_requirements, -> { distinct }, join_table: 'hlr_mfs'

  # Associate Model Files with Low-Level Requirements
  has_and_belongs_to_many :low_level_requirements,  -> { distinct }, join_table: 'llr_mfs'

  # Associate Model Files with Test Cases
  has_and_belongs_to_many :test_cases,              -> { distinct }, join_table: 'tc_mfs'

  has_one_attached        :upload_file, dependent: false

  # Validations
  # Validate only size. Do not validate if file is not attached.
  validates               :upload_file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { upload_file.attached? }

  validates               :model_id,    presence: true
  validates               :full_id,     presence: true
  validates               :project_id,  presence: true

  # Instantiate variables not in database
  attr_accessor           :pact_file
  attr_accessor           :selected
  attr_accessor           :full_id_prefix
  attr_accessor           :release_model_file
  attr_accessor           :archive_revision
  attr_accessor           :archive_version

  @@model_files_path = nil

  # Generate Long ID, full_id + model_id + item_id
  def long_id
    item_id   = if self.item_id.present?
                item = Item.find_by(id: self.item_id)

                item.present? ? item.identifier : ''
              else
                ''
              end
    object_id = if self.model_id.present?
                  self.model_id.to_s
                else
                  ''
                end

    result    = self.full_id + ':'
    result   += object_id + ':'
    result   += item_id

    return result
  end

  def self.full_id_from_id(id)
    result     = nil

    return result unless id.present?

    model_file = self.find_by(id: id) if id.present?
    result     = model_file.full_id   if model_file.present?

    return result
  end

  def self.id_from_full_id(id)
    result     = nil

    return result unless id.present?

    model_file = if id.kind_of?(Integer)
                   self.find_by(id: id)
                 elsif id =~ /^\d+\.*\d*$/
                   self.find_by(id: id.to_i)
                 else
                   self.find_by(full_id: id)
                 end
    result     = model_file.id if model_file.present?

    return result
  end

  # Generate Item identifier + Model ID
  def full_model_id
    unless self.full_id.present?
      self.full_id = "#{self.project.model_file_prefix}-#{sprintf('%03d', self.model_id)}"
    end

    self.full_id
  end

  # Generate Model ID + description.
  def full_model_id_plus_description
    if description.present?
      full_model_id + ' - ' + description
    else
      full_model_id
    end
  end

  def get_system_requirement
    return system_requirements.first
  end

  def get_high_level_requirement
    return high_level_requirements.first
  end

  def get_low_level_requirement
    return low_level_requirements.first
  end

  def get_test_case
    return test_cases.first
  end

  def get_root_path
    path   = ''

    unless @@model_files_path.present?
      local            = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root             = local['root']                         if local.present?
      @@model_files_path = File.join(root,
                                     'model_files',
                                     User.current.organization) if root.present?
    end

    path = @@model_files_path
  end

  def get_file_path
    if self.file_path.present?
      File.join(get_root_path, File.basename(self.file_path))
    else
      get_root_path
    end
  end

  def get_file_contents
    filename = if self.file_path.present? && File.exist?(self.file_path)
                 self.file_path
               else
                 get_file_path
               end

    if filename.present? && File.exist?(filename) && File.ftype(filename) == 'file'
      File.open(filename, 'rb') { |f| f.read }
    else
      nil
    end
  end

  def store_file(file, add_version = false, increment_version = false)
    if file.instance_of?(ActiveStorage::Attached::One)
      self.file_path = file.filename
    else
      return unless file.tempfile.present?

      self.file_path = file.original_filename
    end

    if add_version
      if increment_version
        self.version = if self.version.present?
                         self.version + 1
                       else
                         1
                       end
      end

      if self.file_path =~ /^(.+)\-(\d)(\..+)$/
        self.file_path = Regexp.last_match[1] + "-#{self.version}" +  Regexp.last_match[3]
      elsif self.file_path =~ /^(.+)(\..+)$/
        self.file_path = Regexp.last_match[1] + "-#{self.version}" +  Regexp.last_match[2]
      else
        self.file_path = "-#{self.version}"
      end
    end

    filename         = get_file_path
    directory        = File.dirname(filename)
    self.upload_date = DateTime.now

    unless Dir.exist?(directory)
      FileUtils.mkpath(directory)
    end

    if filename.present?
      if file.instance_of?(ActiveStorage::Attached::One)
        File.open(filename, 'wb') { |f| f.write(file.download) }
      else
        file.tempfile.rewind
        File.open(filename, 'wb') { |f| f.write(file.tempfile.read) }

        self.file_type = file.content_type
      end

      self.file_path   = filename
    else
      nil
    end
  end

  def replace_file(file, project_id, item_id, session_id = nil)
    archive                    = Archive.new()
    title                      = "Update of #{I18n.t('misc.model_file')} ID: #{self.full_id}, " \
                                 "Version #{self.version}."
    archive.name,              = title
    archive.full_id,           = title
    archive.description        = title
    archive.revision           = "1"
    archive.version            = "1"
    archive.archive_type       = Constants::MODEL_CHANGE
    archive.project_id         = project_id
    archive.item_id            = item_id
    archive.archive_project_id = project_id
    archive.archive_item_id    = item_id
    archive.archived_at        = DateTime.now()
    archive.organization       = User.current.organization
    data_change                = DataChange.save_or_destroy_with_undo_session(archive,
                                                                              'create',
                                                                              nil,
                                                                              'archives',
                                                                              session_id)
    session_id                 = data_change.session_id if data_change.present?

    archive.clone_model_file(self, self.project_id, self.item_id, session_id)
    self.store_file(file, true, true)
    file.tempfile.rewind

    begin
      self.upload_file.attach(io:           file.tempfile,
                              filename:     file.original_filename,
                              content_type: file.content_type)
    rescue Errno::EACCES
      self.upload_file.attach(io:           file.tempfile,
                              filename:     file.original_filename,
                              content_type: file.content_type)
    end

    DataChange.save_or_destroy_with_undo_session(self,
                                                 'update',
                                                 self.id,
                                                 'model_files',
                                                 session_id)
  end

  def update_version(session_id = nil)
  end

  def release_revision(session_id = nil)
  end

  def self.rename_prefix(project_id, item_id, old_prefix, new_prefix,
                         session_id = nil)
    return true unless project_id.present? &&
                       item_id.present?    &&
                       old_prefix.present? &&
                       new_prefix.present? &&
                       (old_prefix != new_prefix)
    project                   = Project.find_by(id: project_id)
    item                      = Item.find_by(id: item_id)

    return false unless project.present? && item.present?

    project.model_file_prefix = new_prefix
    item.model_file_prefix    = new_prefix
    change_record             = DataChange.save_or_destroy_with_undo_session(project,
                                                                             'update',
                                                                             project.id,
                                                                             'projects',
                                                                             session_id)

    return false unless change_record.present?

    session_id                = change_record.session_id

    return false unless DataChange.save_or_destroy_with_undo_session(item,
                                                                     'update',
                                                                     item.id,
                                                                     'items',
                                                                     session_id)

    model_files               = ModelFile.where(project_id:   project_id,
                                                item_id:      item_id,
                                                organization: User.current.organization)

    model_files.each do |model_file|
      if model_file.full_id.present?
        next unless model_file.full_id.sub!(old_prefix, new_prefix).present?
      else
        model_file.full_id    = model_file.full_model_id
      end

      return false unless DataChange.save_or_destroy_with_undo_session(model_file,
                                                                       'update',
                                                                       model_file.id,
                                                                       'model_files',
                                                                       session_id)
    end if model_files.present?

    return true
  end

  def self.renumber(item_type,
                    item_id,
                    start      = 1,
                    increment  = 1,
                    prefix     = 'HLR-',
                    padding    = 3)

    prefix                       = prefix.sub(/\-$/, '')
    session_id                   = nil

    if item_type == :item
      model_files                  = ModelFile.where(item_id:      item_id,
                                                     organization: User.current.organization).order(:model_id)
      maximum_model_id             = ModelFile.where(item_id:      item_id,
                                                     organization: User.current.organization).maximum(:model_id)
    else
      model_files                  = ModelFile.where(project_id:   item_id,
                                                     organization: User.current.organization).order(:model_id)
      maximum_model_id             = ModelFile.where(project_id:   item_id,
                                                     organization: User.current.organization).maximum(:model_id)
    end

    maximum_model_id            += 1 if maximum_model_id.present?

    model_files.each do |model_file|
      model_file.model_id        = start
      model_file.full_id         = prefix + sprintf("-%0*d", padding, start)

      if item_type == :item
        existing_record            = ModelFile.find_by(model_id:     start,
                                                       item_id:      item_id,
                                                       organization: User.current.organization)
      else
        existing_record            = ModelFile.find_by(model_id:     start,
                                                       project_id:   item_id,
                                                       organization: User.current.organization)
      end

      if existing_record.present?
        existing_record.model_id = maximum_model_id
        maximum_model_id        += 1
        change_record            = DataChange.save_or_destroy_with_undo_session(existing_record,
                                                                                'update',
                                                                                existing_record.id,
                                                                                'model_files', 
                                                                                session_id)
        session_id               = change_record.session_id if change_record.present?
      end

      change_record              = DataChange.save_or_destroy_with_undo_session(model_file,
                                                                                'update',
                                                                                model_file.id,
                                                                                'model_files', 
                                                                                session_id)
      session_id                 = change_record.session_id if change_record.present?
      start                     += increment
    end if model_files.present?
  end

  def self.get_model_files(project_id, item_id = nil)
    result = if item_id.present?
               RequirementsTracing.sort_on_full_id(ModelFile.where(item_id:      item_id,
                                                                   organization: User.current.organization).order(:full_id))
             else
               RequirementsTracing.sort_on_full_id(ModelFile.where(project_id:   project_id,
                                                                   organization: User.current.organization).order(:full_id))
             end

    return result
  end

  def self.duplicate_file(folder,
                          filename,
                          file_object,
                          use_link = false,
                          use_file = false)
    url_type          = nil
    url_link          = nil
    file              = nil
    path              = folder.get_file_path
    file_path         = File.join(path, filename)

    if use_link
      url_type        = file_object.link_type
      url_link        = file_object.link_link
    else
      url_type        = file_object.url_type
      url_link        = file_object.url_link
    end

    if use_file
      file            = file_object.file        if file_object.file.attached?
    else
      file            = file_object.upload_file if file_object.upload_file.attached?
    end

    FileUtils.mkpath(path) unless Dir.exist?(path)

    if url_type == 'ATTACHMENT'
      if file.present?
        File.open(file_path, 'wb') { |f| f.write(file.download) }
      else
        file_path     = nil
      end
    elsif url_type == 'PACT'
      model_file        = nil

      if url_link =~ /.*\/(\d+)$/
        model_file      = ModelFile.find(Regexp.last_match[1])
      end

      if model_file.present?
        File.open(file_path, 'wb') { |f| f.write(model_file.get_file_contents) }
      else
        file_path     = nil
      end
    elsif url_type == 'EXTERNAL'
      download_link   = nil

      if url_link =~ /^https:\/\/gitlab.faaconsultants.com\/.*$/

        gitlab_access = GitlabAccess.find_by(user_id: User.current.id)

        if gitlab_access.present? && gitlab_access.token.present?
          download_link = url_link.gsub('/blob/', '/raw/') + '?inline=false&private_token=' + gitlab_access.token
        end
      end

      if download_link.present?
        uri           = URI.parse(download_link)
        http          = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl  = true
        response      = http.get(uri.request_uri)

        File.open(file_path, 'wb') { |f| f.write(response.body) }
      else
        file_path     = nil
      end
    end

    return file_path
  end

  def self.add_model_file(object, file, item_id, session_id = nil)
    result                   = nil
    item                     = Item.find(item_id)
    filename                 = if file.try(:original_filename)
                                 file.original_filename
                               elsif file.try(:filename)
                                 file.filename
                               elsif file.try(:name)
                                 file.name
                               else
                                 ''
                               end
      model_file             = ModelFile.new()
      maximium_model_id      = ModelFile.where(item_id: item_id).maximum(:model_id)
      model_file.model_id    = maximium_model_id.present? ? maximium_model_id + 1 : 1
      model_file.full_id     = item.model_file_prefix +
                               sprintf("%04d", model_file.model_id)
      model_file.description = File.basename(filename)
      model_file.file_type   = file.content_type
      model_file.file_path   = filename
      model_file.item_id     = item_id
      model_file.project_id  = object.project_id
      table_name             = object.class.name.tableize

      case table_name
        when 'system_requirements'
          model_file.system_requirement_associations     = object.id.to_s
        when 'high_level_requirements'
          model_file.high_level_requirement_associations = object.id.to_s
        when 'low_level_requirements'
          model_file.low_level_requirement_associations  = object.id.to_s
        when 'test_cases'
          model_file.test_case_associations              = object.id.to_s
      end

      data_change            = DataChange.save_or_destroy_with_undo_session(model_file,
                                                                            'create',
                                                                            nil,
                                                                            'model_files',
                                                                            session_id)

      return result unless data_change.present?

      session_id             = data_change.session_id

      model_file.store_file(file)
      file.tempfile.rewind

      begin
        model_file.upload_file.attach(io:           file.tempfile,
                                      filename:     file.original_filename,
                                      content_type: file.content_type)
      rescue Errno::EACCES
        model_file.upload_file.attach(io:           file.tempfile,
                                      filename:     file.original_filename,
                                      content_type: file.content_type)
      end

      data_change = DataChange.save_or_destroy_with_undo_session(model_file,
                                                                 'update',
                                                                 model_file.id,
                                                                 'model_files',
                                                                 session_id)

      return result unless data_change.present?

      object.model_file_id   = model_file.id
      data_change            = DataChange.save_or_destroy_with_undo_session(object,
                                                                            'update',
                                                                            object.id,
                                                                            table_name,
                                                                            session_id)

      return result unless data_change.present?

      result = model_file if Associations.build_associations(model_file)

      return result
  end

  def self.replace_model_file_file(model_file_id, file, session_id = nil)
    id       = if model_file_id =~ /^\d+$/
                 model_file_id.to_i
               elsif model_file_id.kind_of?(Integer)
                 model_file_id
               end

    return unless id.present?

    model_file = ModelFile.find(id)

    model_file.replace_file(file, model_file.project_id, model_file.item_id,
                            session_id)

    return model_file
  end

  # CSV file handling
  DEFAULT_HEADERS = %w{id model_id full_id description file_path file_type url_type url_description url_link soft_delete derived derived_justification system_requirement_associations high_level_requirement_associations low_level_requirement_associations test_case_associations version revision draft_version revision_date organization project_id item_id archive_id created_at updated_at upload_date}

  def get_columns(text_only = true, headers = DEFAULT_HEADERS)
    columns     = []

    headers.each do |attribute|
      value     = self[attribute]

      case attribute
        when 'system_requirement_associations'
          value = Associations.get_associations_as_full_ids('system_requirements',
                                                            'model_files',
                                                            project_id,
                                                            value,
                                                            true)
        when 'high_level_requirement_associations'
          if item_id.present? && (item_id > 0)
            value = Associations.get_associations_as_full_ids('high_level_requirements',
                                                              'model_files',
                                                              item_id,
                                                              value,
                                                              true)
          else
            value = Associations.get_associations_as_full_ids('high_level_requirements',
                                                              'model_files',
                                                              project_id,
                                                              value,
                                                              true)
          end
        when 'low_level_requirement_associations'
          if item_id.present? && (item_id > 0)
            value = Associations.get_associations_as_full_ids('low_level_requirements',
                                                              'model_files',
                                                              item_id,
                                                              value,
                                                              true)
          else
            value = Associations.get_associations_as_full_ids('low_level_requirements',
                                                              'model_files',
                                                              project_id,
                                                              value,
                                                              true)
          end
        when 'test_case_associations'
          if item_id.present? && (item_id > 0)
            value = Associations.get_associations_as_full_ids('test_cases',
                                                              'model_files',
                                                              item_id,
                                                              value,
                                                              true)
          else
            value = Associations.get_associations_as_full_ids('test_cases',
                                                              'model_files',
                                                              project_id,
                                                              value,
                                                              true)
          end
        when 'description'
          value = Sanitize.fragment(value).gsub('&nbsp;',
                                                ' ').strip if value.kind_of?(String)
        when 'project_id'
          value = Project.name_from_id(value)
        when 'item_id'
          value = Item.identifier_from_id(value)
        when 'archive_id'
          value = Archive.full_id_from_id(value)
        when 'model_file_id'
          value = ModelFile.full_id_from_id(value)
        when 'document_id'
          value = Document.docid_from_id(value)
        when 'verification_method'
          value = value.join(',')
        else
          value = Sanitize.fragment(value).gsub('&nbsp;',
                                                ' ').strip if text_only &&
                                                              value.kind_of?(String)
      end

      columns.push(value)
    end

    return columns
  end

  # Create csv
  def self.to_csv(project_id, item_id = nil, headers = DEFAULT_HEADERS)

    CSV.generate(headers: true) do |csv|
      csv << self.column_names

      model_files = self.get_model_files(project_id, item_id)

      model_files.each { |mf| csv << mf.get_columns(true, headers) }
    end
  end

  def self.to_xls(project_id, item_id = nil, headers = DEFAULT_HEADERS)
    xls_workbook   = Spreadsheet::Workbook.new
    xls_worksheet  = xls_workbook.create_worksheet
    current_row    = 0

    xls_worksheet.insert_row(current_row, headers)

    current_row   += 1

    model_files    = self.get_model_files(project_id, item_id)

    model_files.each do |model_file|
      xls_worksheet.insert_row(current_row, model_file.get_columns(false, headers))

      current_row += 1
    end

    file           = Tempfile.new('model-file')

    xls_workbook.write(file.path)
    file.rewind

    result = file.read

    file.close
    file.unlink

    return result
  end

  # Import File Routines

  # The normal Usage would be: ModelFile.from_file('filename.csv', @item)

  # Method:      assign_column
  # Parameters:  column_name a String,
  #              The name of the column to be assigned.
  #
  #              value an object,
  #              The value to set the column to.
  #              
  # Return:      A Boolean, true if the value was assigned false otherwise.
  # Description: Assignes a value to a specic value in the ModelFile
  # Calls:       None
  # Notes:       
  # History:     06-03-2020 - First Written, PC

  def assign_column(column_name, value, item_id)
    result                         = false

    case column_name
      when 'id'
        result              = true

      when 'project_id'
        self.project_id     = Project.id_from_name(value) unless self.project_id.present?
        result              = true

      when 'item_id'
        unless self.item_id.present?
          if item_id.present?
            self.item_id    = item_id
          else
            self.item_id    = Item.id_from_identifier(value)
          end
        end
        result              = true

      when 'model_id'
        if value =~ /^\d+\.*\d*$/
          self.model_id            = value.to_i
          result                   = true
        elsif value.nil?
          result                   = true
        end

      when 'full_id'
        self.full_id               = value
        result                     = true

      when 'description'
        self.description           = value
        result                     = true

      when 'file_path'
        self.file_path             = value
        result                     = true

      when 'file_type'
        self.file_type             = value
        result                     = true

      when 'url_type'
        self.url_type              = value
        result                     = true

      when 'url_link'    
        self.url_link              = value
        result                     = true

      when 'url_description'
        self.url_description       = value
        result                     = true

      when 'soft_delete'
        self.soft_delete           = if value =~ /^true$/i ||
                                       value =~ /^y(es){0,1}$/i
                                       true
                                     elsif value =~ /^false$/i ||
                                          value =~ /^n[o]{0,1}$/i
                                       false
                                     else
                                       nil
                                     end
        result                     = true

      when 'derived'
        self.derived               = if value =~ /^true$/i ||
                                       value =~ /^y(es){0,1}$/i
                                       true
                                     elsif value =~ /^false$/i ||
                                          value =~ /^n[o]{0,1}$/i
                                       false
                                     else
                                       nil
                                     end
        result                         = true

      when 'derived_justification'
        self.derived_justification = value
        result                     = true

      when 'system_requirement_associations'
        self.system_requirement_associations = Associations.set_associations_from_full_ids('system_requirements',
                                                                                           'model_files',
                                                                                           self.project_id,
                                                                                           value,
                                                                                           true)
        result                               = true

      when 'high_level_requirement_associations'
        if self.item_id.present? && (self.item_id > 0)
          self.high_level_requirement_associations = Associations.set_associations_from_full_ids('high_level_requirements',
                                                                                                 'model_files',
                                                                                                 self.item_id,
                                                                                                 value,
                                                                                                 true)
        else
          self.high_level_requirement_associations = Associations.set_associations_from_full_ids('high_level_requirements',
                                                                                                 'model_files',
                                                                                                 self.project_id,
                                                                                                 value,
                                                                                                 true)
        end

        result                                   = true

      when 'low_level_requirement_associations'
        if self.item_id.present? && (self.item_id > 0)
          self.low_level_requirement_associations  = Associations.set_associations_from_full_ids('low_level_requirements',
                                                                                                 'model_files',
                                                                                                 self.item_id,
                                                                                                 value,
                                                                                                 true)
        else
          self.low_level_requirement_associations  = Associations.set_associations_from_full_ids('low_level_requirements',
                                                                                                 'model_files',
                                                                                                 self.project_id,
                                                                                                 value,
                                                                                                 true)
        end

        result                                   = true

      when 'test_case_associations'
        if self.item_id.present? && (self.item_id > 0)
          self.test_case_associations              = Associations.set_associations_from_full_ids('test_cases',
                                                                                                 'model_files',
                                                                                                 self.item_id,
                                                                                                 value,
                                                                                                 true)
        else
          self.test_case_associations              = Associations.set_associations_from_full_ids('test_cases',
                                                                                                 'model_files',
                                                                                                 self.project_id,
                                                                                                 value,
                                                                                                 true)
        end

        result                                   = true

      when 'version'
        if value =~ /^\d+\.*\d*$/
          self.version             = value.to_i
          result                   = true
        elsif value.nil?
          self.version             = value
          result                   = true
        end

      when 'revision'
        self.revision              = value
        result                     = true

      when 'draft_version'
        self.draft_version         = value
        result                     = true

      when 'revision_date'
        if value.present?
          begin
            self.revision_date = DateTime.parse(value)
            result                 = true
          rescue
            result                 = false
          end
        else
          result                   = true
        end

      when 'archive_id'
        self.archive_id     = Archive.id_from_full_id(value)
        result              = true

      when 'created_at'
        if value.present?
          begin
            self.created_at      = DateTime.parse(value)
            result               = true
          rescue
            result               = false
          end
        else
          result                 = true
        end

      when 'updated_at'
        if value.present?
          begin
            self.updated_at      = DateTime.parse(value)
            result               = true
          rescue
            result               = false
          end
        else
          result                 = true
        end

      when 'organization'
        result              = true

      when 'upload_date'
        if value.present?
          begin
            self.upload_date = DateTime.parse(value)
            result                 = true
          rescue
            result                 = false
          end
        else
          result                   = true
        end

      when 'archive_revision'
        self.archive_revision      = value
        result                     = true

      when 'archive_version'
        self.archive_version       = value.to_f if value.present?
        result                     = true
    end

    return result
  end

  # Method:      process_row
  # Parameters:  columns an array; the columns to process.
  #
  #              project_id an optional Project_id (default: default from @project_id),
  #              The project_id this model file belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the XLSX file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLSX file into the System Requiremens.
  # Calls:       find_or_create_model file_by_id, assign_column
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.process_row(columns,
                       project_id,
                       item_id,
                       check_download = [],
                       session_id     = [ nil ],
                       headers        = DEFAULT_HEADERS)
    return true if !columns.present? || (columns[0] == headers[0])

    compare_associations = {}
    result               = false
    model_file           = self.find_or_create_model_file_by_id(columns,
                                                                project_id,
                                                                item_id,
                                                                headers)

    return result unless model_file.present?

    if check_download.include?(:check_duplicates) && model_file.id.present?
      return :duplicate_model_file
    end

    if check_download.include?(:check_associations)
      compare_associations['system_requirement_associations']     = [ model_file.system_requirement_associations,     nil ]
      compare_associations['high_level_requirement_associations'] = [ model_file.high_level_requirement_associations, nil ]
      compare_associations['low_level_requirement_associations']  = [ model_file.low_level_requirement_associations,  nil ]
      compare_associations['test_case_associations']              = [ model_file.test_case_associations,              nil ]
    end

    columns.each_with_index do |column, index|
      column_name        = if index < headers.length
                             headers[index]
                           else
                             nil
                           end

      if column_name.present?
        result           = model_file.assign_column(column_name, column,
                                                    item_id)

        if check_download.include?(:check_associations) && result
          array          = compare_associations[column_name]

          if array.present?
            array[1]                          = model_file[column_name]
            compare_associations[column_name] = array
          end
        end
      end

      break unless result
    end

    if check_download.include?(:check_associations)
      compare_associations.each do |column, array|
        return :model_file_requirement_associations_changed if array[0] !=
                                                               array[1]
      end
    end

    unless check_download.present?
      operation          = model_file.id.present? ? 'update' : 'create'
      change_record      = DataChange.save_or_destroy_with_undo_session(model_file,
                                                                        operation,
                                                                        model_file.id,
                                                                        'model_files', 
                                                                        session_id[0])
      session_id[0]      = change_record.session_id if change_record.present?

      if change_record.present?
        result                          = Associations.build_associations(model_file)
        result                          = change_record if result
      end
    end

    return result
  end

  # Method:      from_xlsx_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              project_id an optional Project_id (default: default from @project_id),
  #              The project_id this model file belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the XLSX file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLSX file into the System Requiremens.
  # Calls:       find_or_create_model file_by_id, process_row
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.from_xlsx_filename(input_filename,
                              project_id,
                              item_id,
                              check_download  = [],
                              headers         = DEFAULT_HEADERS,
                              file_has_header = true)
    columns             = []
    result              = nil
    session_id          = [ nil ]
    xlsx_workbook       = Roo::Excelx.new(input_filename)

    xlsx_workbook.sheets.each do |xlsx_worksheet|
      first_row         = xlsx_workbook.first_row(xlsx_worksheet)
      last_row          = xlsx_workbook.last_row(xlsx_worksheet)

      next if first_row.nil? || last_row.nil?

      if file_has_header
        found           = false

        while (first_row < last_row) && !found
          columns       = xlsx_workbook.row(first_row, xlsx_worksheet)

          columns.each do |cell|
            next unless cell.present?

            found       = (cell.to_s == headers[0])

            if found
              headers   = []

              columns.each do |column|
                column  = '' unless column.present?

                headers.push(column.to_s)
              end unless columns.nil?

              break
            end
          end unless columns.nil?

          first_row    += 1

          break if found
        end
      else
        current_row     = first_row

        while (current_row < last_row) && !found
          columns       = xlsx_workbook.row(current_row, xlsx_worksheet)

          columns.each do |cell|
            next unless cell.present?

            found       = (cell.to_s == headers[0])

            if found
              first_row = current_row + 1

              break
            end
          end unless columns.nil?

          current_row  += 1

          break if found
        end
      end

      for row in first_row...(last_row + 1) do
        columns         = []
        row_columns     = xlsx_workbook.row(row, xlsx_worksheet)
        
        row_columns.each do |cell|
          if cell.nil?
            columns.push(nil)
          else
            columns.push(cell.to_s)
          end
        end unless columns.nil?

        result          = self.process_row(columns, project_id, item_id, check_download,
                                           session_id, headers)

        return result unless result == true
      end
    end

    result              = true

    return result
  end

  # Method:      from_xls_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              item_id, the item_id this model file belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the XLS file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLS file into the Test Cases.
  # Calls:       find_or_create_model file_by_id, process_row
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.from_xls_filename(input_filename,
                             project_id,
                             item_id,
                             check_download  = [],
                             headers         = DEFAULT_HEADERS,
                             file_has_header = true)
    result                             = false
    session_id                         = [ nil ]
    xls_workbook                       = Spreadsheet.open(input_filename)

    xls_workbook.worksheets.each do |xls_worksheet|
      dimensions                       = xls_worksheet.dimensions
      first_row                        = dimensions[0]
      last_row                         = dimensions[1]
      first_column                     = dimensions[2]
      last_column                      = dimensions[3]
      columns                          = []
      column_number                    = 0

      next if (first_row == last_row) # Empty Spreadsheet

      if (first_column == last_column)
        # There's a bug either in OpenDoc or the spreadsheet gem.
        # Find out if the spreadsheet is truly empty
        for current_row in first_row..[last_row, (first_row + 30)].min
          current_col                  = first_column
          try_col                      = current_col

          while ((cell_contents = xls_worksheet.cell(current_row,
                                                     try_col)) != nil) ||
                 (try_col < 5)
            try_col                   += 1
            current_col                = try_col unless cell_contents.nil?
          end

          last_column                  = current_col if current_col > last_column
        end
      end

      next if (first_column == last_column) # Empty Spreadsheet

      if file_has_header
        found                          = false

        while (first_row < last_row) && !found
          for current_col in first_column..last_column
            found = (xls_worksheet.cell(first_row, current_col) == headers[0])

            if found
              first_column             = current_col
              column_number            = 0

              for current_col in first_column..last_column
                value                  = xls_worksheet.cell(first_row,
                                                            current_col)
                columns[column_number] = value.to_s if value.present?
                column_number         += 1        
              end

              headers                  = columns

              break
            end
          end

          first_row                   += 1 if found
        end

        return result if first_row >= last_row
      else
        current_row                    = first_row

        while (current_row < last_row) && !found
          for current_col in first_column..last_column
            found = (xls_worksheet.cell(current_row, current_col) == headers[0])

            if found
              for current_col in first_column..last_column
                value                  = xls_worksheet.cell(current_row,
                                                            current_col)
                columns[column_number] = value.to_s if value.present?
                column_number         += 1        
              end

              current_row             += 1
              break
            end
          end

          first_row                    = current_row if found
          current_row                 += 1
        end
      end

      for row in first_row...last_row do
        columns                        = []
        column_number                  = 0

        for current_col in first_column..last_column
          columns[column_number]       = xls_worksheet.cell(row, current_col)
          columns[column_number]       = columns[column_number].to_s if columns[column_number].present?
          column_number               += 1        
        end

        result                         = self.process_row(columns,
                                                          project_id,
                                                          item_id,
                                                          check_download,
                                                          session_id,
                                                          headers)

        return result unless result == true
      end
    end

    result                             = true

    return result
  end

  # Method:      from_csv_string
  # Parameters:  line a String,
  #              The line from the CSV File
  #
  #              item_id, the item_id this model file belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       find_or_create_model file_by_id, process_row
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.from_csv_string(line,
                           project_id,
                           item_id        = nil,
                           check_download = [],
                           headers        = DEFAULT_HEADERS,
                           session_id     = [ nil ])
    result      = false
    columns     = []

    begin
      if line.kind_of?(String)
        columns = CSV.parse_line(line)
      elsif line.kind_of?(Array)
        columns = line
      end

      result    = self.process_row(columns, project_id, item_id, check_download,
                                   session_id, headers)
    rescue => e
      message   = "Cannot parse CSV.\nError: #{e.message}.\nLine:  '#{line}'"

      if item_id.present?
        item = Item.find(item_id)

        item.errors.add(:name, :blank, message: message)  
      else
        project = Project.find(project_id)

        project.errors.add(:name, :blank, message: message)  
      end

      return result
    end

    return true unless columns.present? # skip empty lines

    return result
  end

  # Method:      from_from_csv_filename
  # Parameters:  filename a String
  #              The filename of the CSV file.
  #
  #              item_id, the item_id this model file belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  #              file_has_header an optional boolean (default: true),
  #              If true the CSV file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.from_csv_filename(filename,
                             project_id,
                             item_id,
                             check_download  = [],
                             headers         = DEFAULT_HEADERS,
                             file_has_header = true)
    result               = false
    first_line           = true
    session_id           = [ nil ]

    if File.readable?(filename)
      CSV.foreach(filename) do |row|
        if first_line && (file_has_header || (row[0] =~ /\s*model_id\s*/))
          headers        = row.map() do |column|
                                       if (column =~ /\s*([A-Za-z_ ]+)\s*/)
                                         Regexp.last_match[1]
                                       else
                                         column
                                       end
                                     end
        else
          change_session = self.from_csv_string(row, project_id, item_id, check_download,
                                                headers, session_id)

          return :duplicate_model_file                        if change_session == :duplicate_model_file
          return :model_file_requirement_associations_changed if change_session == :model_file_requirement_associations_changed

          next if change_session == :skip

          return result unless change_session.present?

          session_id[0] = change_session.session_id if change_session.instance_of?(ChangeSession)
        end

        first_line = false
      end

      result = true
    else
      message = "The file '#{filename}' is not readable or does not exist."

      if item_id.present?
        item = Item.find(item_id)

        item.errors.add(:name, :blank, message: message)  
      else
        project = Project.find(project_id)

        project.errors.add(:name, :blank, message: message)  
      end
    end

    return result
  end

  # Method:      from_csv_io
  # Parameters:  file an IO,
  #              The opened input stream.
  #
  #              item_id, the item_id this model file belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.from_csv_io(file,
                       project_id,
                       item_id,
                       check_download = [],
                       headers        = DEFAULT_HEADERS)
    result       = false
    session_id   = [ nil ]

    while (line = io.readline)
      result     = self.from_csv_string(line, project_id, item_id, check_download,
                                        headers, session_id)

      return :duplicate_model_file if result == :duplicate_model_file

      next if result == :skip

      session_id[0] = result.session_id if result.instance_of?(ChangeSession)

      break unless result
    end

    return result
  end

  # Method:      from_file
  # Parameters:  input a String or IO,
  #              if a string it's either a filename or a line from a file.
  #              If it's an IO it's an opened input stream.
  #
  #              item_id, the item_id this model file belongs to.
  #
  #              check_download an optional array of symbols (default: []).
  #                if not empty record is only checked and not saved.
  #                  :check_duplicates checks for duplicate ids.
  #                  :check_associations checks to see of associations have changed.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a file into the models.
  # Calls:       from_csv_file, from_csv_io, or from_csv_string
  # Notes:       If the model file already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last model file id.
  # History:     06-03-2020 - First Written, PC

  def self.from_file(input,
                     project_id,
                     item_id         = nil,
                     check_download  = [],
                     headers         = DEFAULT_HEADERS,
                     file_has_header = true)
    result = false

    if input.kind_of?(String)
      if input =~ /^.+\.csv$/i # If it's a csv filename
        result = self.from_csv_filename(input, project_id, item_id,  check_download, headers,
                                        file_has_header)
      elsif input =~ /^.+\.xlsx$/i # If it's an xlsx file
        result = self.from_xlsx_filename(input, project_id, item_id,  check_download, headers,
                                         file_has_header)
      elsif input =~ /^.+\.xls$/i # If it's an xls file
        result = self.from_xls_filename(input, project_id, item_id,  check_download, headers,
                                        file_has_header)
      else                     # If is a line from a csv file
        result = self.from_csv_string(input, project_id, item_id,  check_download, headers)
      end
    elsif input.kind_of?(IO)    # If it's an input stream
      result = self.from_csv_io(input, project_id, item_id,  check_download, headers)
    end

    return result
  end

  def get_file_contents
    result         = nil

    return unless self.url_type.present?

    case(self.url_type)
      when 'ATTACHMENT'
        result     = self.upload_file if self.upload_file.attached?

      when 'EXTERNAL'
        result     =  URI.parse(self.url_link) if self.url_link.present?

      when 'INSTRUMENTED'
        result     = File.read(self.url_link) if File.readable?(self.url_link)

      when 'PACT'
        if self.url_link =~ /.*\/(\d+)$/
          model_file = ModelFile.find(Regexp.last_match[1])
        end

        result     = model_file.get_file_contents if model_file.present?
    end

    return result
  end

private
  # Method:      find_or_create_model_file_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the model_id).
  #
  #              item_id, the item_id this requirement belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      A Low Level Requirement Object.
  # Description: Finds or Creates a Low Level Requirement Object by the ID in the line.
  # Calls:       None
  # Notes:       If the requirement already exists it is returned otherwise a
  #              a new one is created. In this case, if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-03-2020 - First Written, PC

  def self.find_or_create_model_file_by_id(columns,
                                           project_id,
                                           item_id,
                                           headers = DEFAULT_HEADERS)
    id_at                   = headers.find_index('model_id')
    id                      = columns[id_at].to_i if id_at.present? &&
                                                     columns[id_at] =~ /^\d+\.*\d*$/

    if id.present?
      if item_id.present?
        model_file = ModelFile.find_by(model_id: id, item_id: item_id)
      else
        model_file = ModelFile.find_by(model_id: id, project_id: project_id)
      end
    else
      last_id               = nil
      model_files           = ModelFile.where(item_id:      item_id,
                                              organization: User.current.organization).order("model_id")

      model_files.each do |requirement|
        if last_id.present? && (last_id != (requirement.model_id - 1)) # we found a hole.
          id                = last_id + 1

          break;
        end

        last_id             = requirement.model_id
      end

      id = if id.present?
             id
           elsif last_id.present?
             last_id + 1
           else
             1
           end
    end

    unless model_file.present?
      model_file            = ModelFile.new()
      model_file.project_id = project_id
      model_file.item_id    = item_id
      model_file.model_id   = id
    end

    return model_file
  end
end
