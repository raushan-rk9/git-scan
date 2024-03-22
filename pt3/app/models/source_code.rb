class SourceCode < OrganizationRecord
  belongs_to              :item
  belongs_to              :project
  has_many                :code_checkmarks,         dependent: :destroy
  has_many                :code_conditional_blocks, dependent: :destroy
  has_many                :function_items,          dependent: :destroy

  # Associate SCs with MDs
  has_and_belongs_to_many :module_descriptions, -> { distinct }, join_table: "md_scs"

  has_one_attached        :image,                   dependent: false
  has_one_attached        :upload_file,             dependent: false

  # Validations
  # Validate only size. Do not validate if file is not attached.
  validates               :upload_file,             file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { upload_file.attached? }

  # Allow only images as attachments
  # Do not validate if image is not attached.
  validates               :image,                   file_size: { less_than_or_equal_to: 10.megabytes }, if: proc { image.attached? }
  validates               :image,                   file_content_type: { allow: ["image/jpeg", "image/gif", "image/png"] }, if: proc { image.attached? }

  validates               :codeid,                  presence: true
  validates               :project_id,              presence: true
  validates               :item_id,                 presence: true

  # Instantiate variables not in database
  attr_accessor           :remove_image
  attr_accessor           :pact_file
  attr_accessor           :selected
  attr_accessor           :full_id_prefix
  attr_accessor           :archive_type
  attr_accessor           :archive_revision
  attr_accessor           :archive_version

  @@source_codes_path = nil

  def self.item_id_from_id(id)
    result      = ''
    source_code = self.find_by(id: id) if id.present?
    result      = source_code.item_id  if source_code.present?

    return result
  end

  def self.code_id_plus_filename_from_id(id)
    result      = ''
    source_code = self.find_by(id: id)              if id.present?
    result      = source_code.code_id_plus_filename if source_code.present?

    return result
  end


  def self.item_name_and_code_id_plus_filename_from_id(id)
    result      = ''
    source_code = self.find_by(id: id)              if id.present?

    return result unless source_code.present?

    result    = source_code.item.name + ' : ' + source_code.code_id_plus_filename

    return result
  end

  def self.file_name_from_id(id)
    result      = ''
    source_code = self.find_by(id: id)  if id.present?
    result      = source_code.file_name if source_code.present?

    return result
  end

  def self.code_plus_description_from_id(id)
    result      = ''
    source_code = self.find_by(id: id)  if id.present?
    result      = source_code.codeidplusdescription if source_code.present?

    return result
  end

  def self.item_name_from_id(id)
    result      = ''
    id          = id.to_s unless id.kind_of?(String)
    source_code = self.find_by(id: id)  if id.present?
    result      = source_code.item.name if source_code.present?

    return result
  end


  # Generate Long ID, full_id + codeid
  def long_id
    result    = ''
    item_id   = if self.item_id.present?
                item = Item.find_by(id: self.item_id)

                item.present? ? item.identifier : ''
              else
                ''
              end
    object_id = if self.codeid.present?
                  self.codeid.to_s
                else
                  ''
                end

    result    = self.full_id + ':' if self.full_id.present?
    result   += object_id + ':'    if object_id.present?
    result   += item_id

    return result
  end

  # Generate Item identifier + codeid + item_id
  def fullcodeid
    full_id = self.codeid

    full_id
  end

  # Generate code ID + description.
  def codeidplusdescription
    result  = "#{fullcodeid} - "

    if file_name.present?
      result += file_name
    end

    if self.module.present?
      if file_name.present?
        result += ':'
      end

      result += self.module
    end

    if function.present?
      if file_name.present? || self.module.present?
        result += ':'
      end

      result += function
    end

    result
  end

  # Generate procedure ID + description.
  def code_id_plus_filename
    result  = "#{fullcodeid} - "

    if file_name.present?
      result += get_filename
    end

    result
  end

  def get_filename
      filename    = ActionView::Base.full_sanitizer.sanitize(file_name)

      filename.gsub!("\r", '')

      if filename.index("\n")
        filenames = filename.split("\n")
        filename  = filenames[0]
      end

      filename
  end

  def get_module_description
    return module_descriptions.first
  end

  def get_high_level_requirement
    return nil
  end

  def get_low_level_requirement
    return nil
  end

  def get_system_requirement
    result                     = nil
    high_level_requirement     = get_high_level_requirement

    if high_level_requirement.present?
      result                   = high_level_requirement.get_system_requirement
    else
      low_level_requirement    = get_low_level_requirement

      if low_level_requirement.present?
        high_level_requirement = low_level_requirement.get_high_level_requirement

        if high_level_requirement.present?
          result               = high_level_requirement.get_system_requirement
        end
      end
    end
    
    return result
  end

  def get_root_path
    path   = ''

    unless @@source_codes_path.present?
      local               = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root                = local['root']                        if local.present?
      @@source_codes_path = File.join(root,
                                      'source_codes',
                                      User.current.organization) if root.present?
    end

    path = @@source_codes_path
  end

  def get_file_path
    if self.file_path.present?
      File.join(get_root_path, File.basename(self.file_path))
    else
      get_root_path
    end
  end

  def get_file_contents
    result         = nil

    return unless self.url_type.present?

    case(self.url_type)
      when Constants::UPLOAD_ATTACHMENT
        result     = self.upload_file if self.upload_file.attached?

      when Constants::EXTERNAL_ATTACHMENT
        result     =  URI.parse(self.url_link) if self.url_link.present?

      when Constants::INSTRUMENTS_ATTACHMENT
        result     = File.read(self.url_link) if File.readable?(self.url_link)

      when Constants::PACT_ATTACHMENT
        if self.url_link =~ /.*\/(\d+)$/
          document = Document.find(Regexp.last_match[1])
        end

        result     = document.get_file_contents if document.present?
    end

    return result
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
    title                      = "Update of #{I18n.t('misc.source_code')} ID: #{self.full_id}, " \
                                 "Version #{self.version}."
    archive.name,              = title
    archive.full_id,           = title
    archive.description        = title
    archive.revision           = "1"
    archive.version            = "1"
    archive.archive_type       = Constants::SOURCE_CODE_CHANGE
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

    archive.clone_source_code(self, self.project_id, self.item_id, session_id)
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
                                                 'source_codes',
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
    project                    = Project.find_by(id: project_id)
    item                       = Item.find_by(id: item_id)

    return false unless project.present? && item.present?

    project.source_code_prefix = new_prefix
    item.source_code_prefix    = new_prefix
    change_record              = DataChange.save_or_destroy_with_undo_session(project,
                                                                              'update',
                                                                              project.id,
                                                                              'projects',
                                                                              session_id)

    return false unless change_record.present?

    session_id                 = change_record.session_id
    
    return false unless DataChange.save_or_destroy_with_undo_session(item,
                                                                     'update',
                                                                     item.id,
                                                                     'items',
                                                                     session_id)

    source_codes                = SourceCode.where(project_id:   project_id,
                                                   item_id:      item_id,
                                                   organization: User.current.organization)

    source_codes.each do |source_code|
      if source_code.full_id.present?
        next unless source_code.full_id.sub!(old_prefix, new_prefix).present?
      else
        source_code.full_id     = source_code.fullcodeid
      end

      return false unless DataChange.save_or_destroy_with_undo_session(source_code,
                                                                       'update',
                                                                       source_code.id,
                                                                       'source_codes',
                                                                       session_id)
    end if source_codes.present?

    return true
  end

  def self.renumber(item_id,
                    start      = 1,
                    increment  = 1,
                    prefix     = 'SC-',
                    padding    = 3)
    prefix                = prefix.sub(/\-$/, '')
    session_id            = nil
    source_codes          = SourceCode.where(item_id: item_id,
                                             organization: User.current.organization).order(:codeid)
    maximum_codeid        = SourceCode.where(item_id:      item_id,
                                             organization: User.current.organization).maximum(:codeid)
    maximum_codeid       += 1

    source_codes.each do |source_code|
      source_code.codeid  = start
      source_code.full_id = prefix + sprintf("-%0*d", padding, start)
      existing_record     = SourceCode.find_by(codeid:        start,
                                               item_id:      item_id,
                                               organization: User.current.organization)

      if existing_record.present?
        existing_record.codeid       = maximum_codeid
        maximum_codeid              += 1
        change_record                = DataChange.save_or_destroy_with_undo_session(existing_record,
                                                                                    'update',
                                                                                    existing_record.id,
                                                                                    'source_codes', 
                                                                                    session_id)
        session_id                   = change_record.session_id if change_record.present?
      end

      change_record       = DataChange.save_or_destroy_with_undo_session(source_code,
                                                                         'update',
                                                                         source_code.id,
                                                                         'source_codes', 
                                                                         session_id)
      session_id          = change_record.session_id if change_record.present?
      start              += increment
    end if source_codes.present?
  end

  # CSV file handling
  DEFAULT_HEADERS = %w{id codeid full_id file_name module function derived derived_justification version item_id project_id url_type url_link url_description created_at updated_at organization low_level_requirement_associations high_level_requirement_associations soft_delete file_path content_type file_type revision draft_version revision_date upload_date external_version archive_revision archive_version module_description_associations }

  def get_columns(text_only = true, headers = DEFAULT_HEADERS)
    columns     = []

    headers.each do |attribute|
      value     = self[attribute]

      case attribute
        when 'high_level_requirement_associations'
          value = Associations.get_associations_as_full_ids('high_level_requirements',
                                                            'source_codes',
                                                            item_id,
                                                            value,
                                                            true)
        when 'low_level_requirement_associations'
          value = Associations.get_associations_as_full_ids('low_level_requirements',
                                                            'source_codes',
                                                            item_id,
                                                            value,
                                                            true)
        when 'description'
          value = Sanitize.fragment(value).gsub('&nbsp;',
                                                ' ').strip if value.kind_of?(String)
        when 'project_id'
          value = Project.name_from_id(value)
        when 'item_id'
          value = Item.identifier_from_id(value)
        when 'archive_id'
          value = Archive.full_id_from_id(value)
        when 'archive_revision'
          if archive_id.present?
            archive = Archive.find(archive_id)
            value   = archive.revision
          end
        when 'archive_version'
          if archive_id.present?
            archive = Archive.find(archive_id)
            value   = archive.version
          end
        when 'module_description_associations'
          value = Associations.get_associations_as_full_ids('module_description',
                                                            'source_codes',
                                                            item_id,
                                                            value,
                                                            true)
        else
      end

      columns.push(value)
    end

    if archive_id.present?
      archive = Archive.find(archive_id)

      columns.push(archive.revision)
      columns.push(archive.version)
    end
    return columns
  end

  # Create csv
  def self.to_csv(item_id, headers = DEFAULT_HEADERS)

    CSV.generate(headers: true) do |csv|
      csv << headers

      source_codes = SourceCode.where(item_id:      item_id,
                                      organization: User.current.organization).order(:full_id)

      RequirementsTracing.sort_on_full_id(source_codes)

      source_codes.each { |sc| csv << sc.get_columns(true, headers) }
    end
  end

  def self.to_xls(item_id, headers = DEFAULT_HEADERS)
    xls_workbook  = Spreadsheet::Workbook.new
    xls_worksheet = xls_workbook.create_worksheet
    current_row   = 0

    xls_worksheet.insert_row(current_row, headers)

    current_row += 1

    source_codes = SourceCode.where(item_id:      item_id,
                                    organization: User.current.organization).order(:full_id)

    RequirementsTracing.sort_on_full_id(source_codes)

    source_codes.each do |sc|
      xls_worksheet.insert_row(current_row, sc.get_columns(false, headers))

      current_row += 1
    end

    file = Tempfile.new('high_level-requirements')

    xls_workbook.write(file.path)
    file.rewind

    result = file.read

    file.close
    file.unlink

    return result
  end

  # Import File Routines

  # The normal Usage would be: SourceCode.from_file('filename.csv', @item)

  # Method:      assign_column
  # Parameters:  column_name a String,
  #              The name of the column to be assigned.
  #
  #              value an object,
  #              The value to set the column to.
  #              
  # Return:      A Boolean, ture if the value was assigned false otherwise.
  # Description: Assignes a valiue to a specic value in the LowLevelRequirement
  # Calls:       None
  # Notes:       
  # History:     06-10-2019 - First Written, PC

  def assign_column(column_name, value, item_id)
    result                         = false

    case column_name
      when 'id'
        result                     = true
      when 'project_id'
        self.project_id            = Project.id_from_name(value) unless self.project_id.present?
        result                     = true
      when 'item_id'
        unless self.item_id.present?
          if item_id.present?
            self.item_id           = item_id
          else
            self.item_id           = Item.id_from_identifier(value)
          end
        end
        result                     = true
      when 'codeid'
        if value =~ /^\d+\.*\d*$/
          self.codeid              = value.to_i
          result                   = true
        elsif !value.present?
          result                   = true
        end
      when 'full_id'
        self.full_id               = value
        result                     = true
      when 'file_name'
        self.file_name             = value
        result                     = true
      when 'module'
        self.module                = value
        result                     = true
      when 'function'
        self.function              = value
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
        result                     = true
      when 'derived_justification'
        self.derived_justification = value
        result                     = true
      when 'version'
        if value =~ /^\d+\.*\d*$/
          self.version             = value.to_i
          result                   = true
        elsif !value.present?
          self.version             = nil
          result                   = true
        end       
      when 'url_type'
        self.url_type              = value
        result                     = true
      when 'url_link'
        if value.present?
          if value.present? && value.index(';').present?
            self.url_link,
            self.self.external_version = value.split(';')
          else
            self.url_link              = value
          end
        end
        result                     = true
      when 'url_description'
        self.url_description       = value
        result                     = true
      when 'high_level_requirement_associations'
        self.high_level_requirement_associations = Associations.set_associations_from_full_ids('high_level_requirements',
                                                                                               'source_codes',
                                                                                               self.item_id,
                                                                                               value,
                                                                                               true)
        result                                   = true
      when 'low_level_requirement_associations'
        self.low_level_requirement_associations  = Associations.set_associations_from_full_ids('low_level_requirements',
                                                                                               'source_codes',
                                                                                               self.item_id,
                                                                                               value,
                                                                                               true)
        result                                   = true
      when 'archive_id'
        self.archive_id            = Archive.id_from_full_id(value)
        result                     = true
      when 'module_description_associations'
        self.module_description_associations  = Associations.set_associations_from_full_ids('module_descriptions',
                                                                                            'source_codes',
                                                                                            self.item_id,
                                                                                            value,
                                                                                            true)
        result                                   = true
      when 'created_at'
        if value.present?
          begin
            self.created_at        = DateTime.parse(value)
            result                 = true
          rescue
            result                 = false
          end
        else
          result                   = true
        end
      when 'updated_at'
        if value.present?
          begin
            self.updated_at        = DateTime.parse(value)
            result                 = true
          rescue
            result                 = false
          end
        else
          result                   = true
        end
      when 'organization'
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
      when 'description'
        self.description              = value
        result                      = true
      when 'file_path'
        self.file_path              = value
        result                      = true
      when 'content_type'
        self.content_type           = value
        result                      = true
      when 'file_type'
        self.file_type              = value
        result                      = true
      when 'revision'
        self.revision               = value
        result                      = true
      when 'draft_version'
        self.draft_version          = value
        result                      = true
      when 'revision_date'
        if value.present?
          begin
            self.revision_date      = DateTime.parse(value)
            result                  = true
          rescue
            result                  = false
          end
        else
          result                    = true
        end
      when 'upload_date'
        if value.present?
          begin
            self.upload_date        = DateTime.parse(value)
            result                  = true
          rescue
            result                  = false
          end
        else
          result                    = true
        end
      when 'external_version'
        self.external_version       = value
        result                      = true

      when 'archive_revision'
        self.archive_revision       = value
        result                      = true

      when 'archive_version'
        self.archive_version       = value.to_f if value.present?
        result                      = true
    end

    return result
  end

  # Method:      process_row
  # Parameters:  columns an array of Strings, the row to process.
  #
  #              item an option Item, the item this record belongs to
  #              (default: nil).
  #
  #              session_id an optional integer, the session_id (default: nil).
  #
  #              check_download an optional array of symbols (default: []).
  #                if not empty record is only checked and not saved.
  #                  :check_duplicates checks for duplicate ids.
  #                  :check_associations checks to see of associations have changed.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS);
  #              the headers for the file.
  #
  # Return:      DataChange if it was processed successfully and saved;
  #              true if error checking and no errors;
  #              :duplicate_high_level_requirement if the id is a duplicate;
  #              :high_level_requirement_associations_changed if the high level requirements associations changed.
  #              :low_level_requirement_associations_changed if the low level requirements associations changed.
  #
  # Description: This imports a row into the Source Codes.
  # Calls:       find_or_create_source_code_by_id, assign_column
  # Notes:       If the source code already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last source code id.
  # History:     06-16-2020 - First Written, PC

  def self.process_row(columns,
                       item             = nil,
                       session_id       = nil,
                       check_download   = [],
                       headers          = DEFAULT_HEADERS)
    result                              = false

    return result unless columns.present?

    source_code                         = self.find_or_create_source_code_by_id(columns,
                                                                                item,
                                                                                headers)

    return result unless source_code.present?

    if check_download.include?(:check_duplicates) && source_code.id.present?
      return :duplicate_source_code
    end

    high_level_requirement_associations = source_code.high_level_requirement_associations
    low_level_requirement_associations  = source_code.low_level_requirement_associations
    module_description_associations     = source_code.module_description_associations

    columns.each_with_index do |column, index|

      column_name                       = if index < headers.length
                                            headers[index]
                                          else
                                            nil
                                          end
      result                            = source_code.assign_column(column_name,
                                                                    column,
                                                                    item.id)     if column_name.present?

      break unless result
    end

    if check_download.include?(:check_associations)       &&
       (high_level_requirement_associations.present?      &&
        (source_code.high_level_requirement_associations !=
         high_level_requirement_associations))
      return :high_level_requirement_associations_changed
    end

    if check_download.include?(:check_associations)                &&
       (low_level_requirement_associations.present?                &&
        (source_code.low_level_requirement_associations !=
         low_level_requirement_associations))
      return :low_level_requirement_associations_changed
    end

    if check_download.include?(:check_associations)                &&
       (module_description_associations.present?                   &&
        (source_code.module_description_associations !=
         module_description_associations))
      return :module_description_associations_changed
    end

    if check_download.empty?
      source_code.full_id               = "SC-#{source_code.codeid}" if !source_code.full_id.present? && source_code.reqid.present?
      operation                         = source_code.id.present? ? 'update' : 'create'
      change_record                     = DataChange.save_or_destroy_with_undo_session(source_code,
                                                                                       operation,
                                                                                       source_code.id,
                                                                                       'source_codes',
                                                                                       session_id)

      if change_record.present?
        result                          = Associations.build_associations(source_code)
        result                          = change_record if result
      end
    else
      result                            = true
    end

    return result
  end

  # Method:      from_csv_string
  # Parameters:  line a String,
  #              The line from the CSV File
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-10-2019 - First Written, PC

  def self.from_csv_string(line,
                           item,
                           check_download = [],
                           headers        = DEFAULT_HEADERS,
                           session_id     = nil)
    result      = false
    columns     = []

    begin
      if line.kind_of?(String)
        columns = CSV.parse_line(line)
      elsif line.kind_of?(Array)
        columns = line
      end
    rescue => e
      message   = "Cannot parse CSV.\nError: #{e.message}.\nLine:  '#{line}'"

      item.errors.add(:name, :blank, message: message)  if item.present?

      return result
    end

    return :skip if columns.empty? # skip empty lines

    result      = process_row(columns, item, session_id, check_download,
                              headers)

    return result
  end

  # Method:      from_file
  # Parameters:  input a String or IO,
  #              if a string it's either a filename or a line from a file.
  #              If it's an IO it's an opened input stream.
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the CSV file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_file, from_csv_io, or from_csv_string
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-10-2019 - First Written, PC

  def self.from_file(input,
                     item            = @item,
                     check_download  = [],
                     headers         = DEFAULT_HEADERS,
                     file_has_header = true)
    result = false

    if input.kind_of?(String)
      if input =~ /^.+\.csv$/i # If it's a csv filename
        result = self.from_csv_filename(input, item,  check_download, headers,
                                        file_has_header)
      elsif input =~ /^.+\.xlsx$/i # If it's an xlsx file
        result = self.from_xlsx_filename(input, item,  check_download, headers,
                                         file_has_header)
      elsif input =~ /^.+\.xls$/i # If it's an xls file
        result = self.from_xls_filename(input, item,  check_download, headers,
                                        file_has_header)
      else                     # If is a line from a csv file
        result = self.from_csv_string(input, item,  check_download, headers)
      end
    elsif input.kind_of?(IO)    # If it's an input stream
      result = self.from_csv_io(input, item,  check_download, headers)
    end

    return result
  end

  # Method:      from_xlsx_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              project an optional Project (default: default from @project),
  #              The project this requirement belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the XLSX file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLSX file into the System Requiremens.
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def self.from_xlsx_filename(input_filename,
                              item            = @item,
                              check_download  = [],
                              headers         = DEFAULT_HEADERS,
                              file_has_header = true)
    columns             = []
    result              = nil
    session_id          = nil
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

        source_code     = self.find_or_create_source_code_by_id(columns, item,
                                                                headers)

        return result unless source_code.present?

        result          = process_row(columns, item, session_id,
                                      check_download, headers)

        if result.kind_of?(ChangeSession)
          session_id    = result.session_id
        elsif (result != :skip) && (result != true) 
          return result
        end
      end
    end

    result              = true

    return result
  end

  # Method:      from_xls_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: true),
  #              If true the XLS file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLS file into the Test Cases.
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def self.from_xls_filename(input_filename,
                             item            = @item,
                             check_download  = [],
                             headers         = DEFAULT_HEADERS,
                             file_has_header = true)
    result                             = false
    xls_workbook                       = Spreadsheet.open(input_filename)
    session_id                         = nil

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

        source_code                    = self.find_or_create_source_code_by_id(columns,
                                                                               item,
                                                                               headers)

        return result unless source_code.present?

        result                         = process_row(columns, item, session_id,
                                                     check_download, headers)

        if result.kind_of?(ChangeSession)
          session_id                   = result.session_id
        elsif (result != :skip) && (result != true) 
          return result
        end
      end
    end

    result                             = true

    return result
  end

  # Method:      from_from_csv_filename
  # Parameters:  filename a String
  #              The filename of the CSV file.
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
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
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-10-2019 - First Written, PC

  def self.from_csv_filename(filename,
                             item            = @item,
                             check_download  = [],
                             headers         = DEFAULT_HEADERS,
                             file_has_header = true)
    result        = false
    first_line    = true
    session_id    = nil

    if File.readable?(filename)
      CSV.foreach(filename) do |row|
        if first_line && (file_has_header || (row[0] =~ /\s*(id|codeid)\s*/))
          headers  = row.map() { |column|  (column =~ /\s*([A-Za-z_ ]+)\s*/) ? $1 : column }
        else
          result   = self.from_csv_string(row, item, check_download, headers,
                                          session_id)

          if result.kind_of?(ChangeSession)
            session_id = result.session_id
          elsif (result != :skip) && (result != true) 
            return result
          end
        end

        first_line = false
      end

      result       = true
    else
      message      = "The file '#{filename}' is not readable or does not exist."

      @item.errors.add(:name, :blank, message: message) if @item.present?
      item.errors.add(:name, :blank, message: message)  if item.present?
    end

    return result
  end

  # Method:      from_csv_io
  # Parameters:  file an IO,
  #              The opened input stream.
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-10-2019 - First Written, PC

  def self.from_csv_io(file,
                       item           = @item,
                       check_download = [],
                       headers        = DEFAULT_HEADERS)
    result       = false
    session_id   = nil

    while (line = io.readline)
      result     = self.from_csv_string(line, item, check_download, headers,
                                        session_id)

      return :duplicate_source_code if result == :duplicate_source_code

      next if result == :skip

      session_id = result.session_id if result.instance_of?(ChangeSession)

      break unless result
    end

    return result
  end

  # Method:      scan_for_functions
  # Parameters:  contents a string,
  #              the contents of the file.
  #
  # Return:      A String containing the list of the functions.
  # Description: This scans the contents of a file and finds any strings.
  # Calls:       
  # Notes:       
  # History:     07-24-2020 - First Written, PC

  def self.scan_for_functions(contents)
    result = []

    return result unless contents.present?

    code   = contents.dup

    code.gsub!(/\r\n/, "\n")
    code.gsub!(/ +/, ' ')
    code.gsub!(/\t/, ' ')

    lines  = code.split("\n")

    lines.each do |line|
      next unless line.present?
      next if line =~ /^\s*EXTERN\s+.*$/

      begin
        Timeout::timeout(5) do
          if line =~ /\s*^([\w\*]+( )*?){2,}\(([^!@#$+%^;]+?)\)(?!\s*;)/i
            result.push(line)
          end
         end
      rescue
      end
    end

    return result
  end

  # Method:      generate_source_codes
  # Parameters:  files an array of Strings,
  #              the files to create source code records for.
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #              
  #              attach_files an optional object, (default nil),
  #              if present, attach the files using the platform
  #              (github or gitlab based on the object). This assumes
  #              that the URL will return the contents of the file.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS)
  #
  # Return:      True if they were generated successfully false otherwise.
  # Description: This generates source code items from a list of file names.
  # Calls:       find_or_create_requirement_by_id scan_for_functions
  # Notes:       
  # History:     09-02-2019 - First Written, PC
  #              07-24-2020 - Added the ability to attach the file automatically.

  def self.generate_source_codes(files,
                                 item         = @item,
                                 attach_files = nil,
                                 headers      = DEFAULT_HEADERS)
    result                        = false
    id_at                         = headers.find_index('codeid')
    filename_at                   = headers.find_index('file_name')
    url_type_at                   = headers.find_index('url_type')
    url_link_at                   = headers.find_index('url_link')
    url_description_at            = headers.find_index('url_description')
    external_version_at           = headers.find_index('external_version')
    session_id                    = nil

    return result unless filename_at.present?

    files.each do |file|
      contents                    = nil
      description                 = ''
      filename                    = ''
      url                         = ''

      if file.index('|') > 0
        filename,
        url                       = file.split('|')
      else
        filename                  = file
      end

      if url.present? && url.index(';').present?
        url,
        id                         = url.split(';')
      end

      if url =~ /^.*\/(.+)$/
        description               = $1
      else
        description               = url
      end

      columns                     = []
      code_id                     = SourceCode.where(item_id: item.id).maximum(:codeid)
      code_id                     = code_id.present? ? (code_id + 1) : 1
      columns[id_at]              = code_id
      columns[filename_at]        = filename
      columns[url_type_at]        = 'EXTERNAL'  if url_type_at.present?
      columns[url_link_at]        = url         if url_link_at.present?
      columns[url_description_at] = description if url_description_at.present?
      columns[external_version_at] = id if external_version_at.present?

      source_code                 = self.find_or_create_source_code_by_id(columns,
                                                                          item)

      if source_code.present?
        columns.each_with_index do |value, index|
          column_name             = if index < headers.length
                                      headers[index]
                                    else
                                      nil
                                    end

          result                  = source_code.assign_column(column_name,
                                                              value.to_s,
                                                              item.id) if column_name.present?
          break unless result
        end
      end

      source_code.version = 1 unless source_code.version.present?

      if attach_files.kind_of?(GitlabAccess)
        contents                  = attach_files.get_file_contents(filename.dup)

        if contents.present?
          source_code.url_type    = Constants::UPLOAD_ATTACHMENT

          if filename =~ /(.+)?\.[ch].{0,3}$/i
            source_code.function  = self.scan_for_functions(contents).join("\n")
          end

          change_session          = DataChange.save_or_destroy_with_undo_session(source_code,
                                                                                 'create',
                                                                                 nil,
                                                                                 'source_codes', 
                                                                                 session_id) unless source_code.id.present?

          begin
            source_code.upload_file.attach(io:       StringIO.new(contents),
                                           filename: filename)
          rescue Errno::EACCES
            source_code.upload_file.attach(io:       StringIO.new(contents),
                                           filename: filename)
          end
        end
      end

      change_session              = DataChange.save_or_destroy_with_undo_session(source_code,
                                                                                 source_code.id.present? ? 'update' : 'create',
                                                                                 source_code.id, 'source_codes', 
                                                                                 session_id)

      if change_session.present?
        session_id                = change_session.session_id

        DataChange.save_or_destroy_with_undo_session(item,
                                                     'update',
                                                     item.id,
                                                     'items',
                                                     change_session.session_id)
      else
        return result
      end
    end

    result                        = true

    return result
  end

  def instrument(session_id      = nil,
                 auto_instrument = false,
                 cmark           = 'CMARK',
                 resetnumbering  = false,
                 starting_number = 0)
    logger.info("Instrumenting Source Code for: #{self.file_name}")
 
    code_checkmarks          = CodeCheckmark.where(organization: User.current.organization,
                                                   source_code_id: self.id)

    code_checkmarks.each { |checkmark| checkmark.delete }

    result                   = false
    instrumented_code_folder = Document.get_or_create_folder(Constants::INSTRUMENTED_CODE,
                                                             self.project_id,
                                                             self.item_id,
                                                             nil,
                                                             session_id)
    file_path                = Document.duplicate_file(instrumented_code_folder,
                                                       self.file_name,
                                                       self)                       if instrumented_code_folder.present?
    result                   = CodeCheckmark.instrument_code_file(file_path,
                                                                  self,
                                                                  session_id,
                                                                  auto_instrument,
                                                                  cmark,
                                                                  resetnumbering,
                                                                  starting_number)  if file_path.present? &&
                                                                                       File.exist?(file_path)

    return result
  end

private
  # Method:      find_or_create_requirement_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the codeid).
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
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
  # History:     06-10-2019 - First Written, PC

  def self.find_or_create_source_code_by_id(columns,
                                            item    = @item,
                                            headers = DEFAULT_HEADERS)
    id_at                    = headers.find_index('codeid')
    id                       = columns[id_at].to_i if id_at.present? &&
                                                      columns[id_at] =~ /^\d+\.*\d*$/
    project                  = Project.find(item.project_id)

    if id.present?
      source_code = SourceCode.find_by(codeid: id, item_id: item.id)
    else
      last_id             = nil
      source_codes = SourceCode.where(item_id: item.id, organization: User.current.organization).order("codeid")

      source_codes.each do |requirement|
        if last_id.present? && (last_id != (requirement.codeid - 1)) # we found a hole.
          id = last_id + 1

          break;
        end

        last_id = requirement.codeid
      end

      id = if id.present?
             id
           elsif last_id.present?
             last_id + 1
           else
             1
           end
    end

    unless source_code.present?
      item.sc_count         += 1
      source_code            = SourceCode.new()
      source_code.project_id = project.id
      source_code.item_id    = item.id
      source_code.codeid     = id
    end

    return source_code
  end
end
