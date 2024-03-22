class TestProcedure < OrganizationRecord
  belongs_to              :item
  belongs_to              :project

  # Associate TCs with TPs
  has_and_belongs_to_many :test_cases,  -> { distinct }, join_table: "tcs_tps"

  has_one_attached        :image,       dependent: false
  has_one_attached        :upload_file, dependent: false

  # Validations
  # Validate only size. Do not validate if file is not attached.
  validates :upload_file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { upload_file.attached? }

  # Allow only images as attachments
  # Do not validate if image is not attached.
  validates :image, file_size: { less_than_or_equal_to: 10.megabytes }, if: proc { image.attached? }
  validates :image, file_content_type: { allow: ["image/jpeg", "image/gif", "image/png"] }, if: proc { image.attached? }

  validates :procedure_id, presence: true
  validates :project_id,  presence: true
  validates :item_id,     presence: true

  # Instantiate variables not in database
  attr_accessor :remove_image
  attr_accessor :pact_file
  attr_accessor :selected
  attr_accessor :full_id_prefix
  attr_accessor :archive_type
  attr_accessor :archive_revision
  attr_accessor :archive_version

  @@test_procedures_path = nil;

  def self.item_id_from_id(id)
    result         = ''
    test_procedure = self.find_by(id: id) if id.present?
    result         = test_procedure.item_id  if test_procedure.present?

    return result
  end

  def self.procedure_id_plus_filename_from_id(id)
    result         = ''
    test_procedure = self.find_by(id: id)                      if id.present?
    result         = test_procedure.procedure_id_plus_filename if test_procedure.present?

    return result
  end

  def self.item_name_and_procedure_id_plus_filename_from_id(id)
    result         = ''
    test_procedure = self.find_by(id: id)                      if id.present?

    return result unless test_procedure.present?

    result         = test_procedure.item.name + ' : ' + test_procedure.procedure_id_plus_filename

    return result
  end

  # Generate Long ID, full_id + procedure_id + item_id
  def long_id
    item_id   = if self.item_id.present?
                item = Item.find_by(id: self.item_id)

                item.present? ? item.identifier : ''
              else
                ''
              end
    object_id = if self.procedure_id.present?
                  self.procedure_id.to_s
                else
                  ''
                end

    result    = self.full_id + ':'
    result   += object_id + ':'
    result   += item_id

    return result
  end

  # Generate Item identifier + procedure_id
  def full_procedure_id
    full_id = self.full_id.present? ? self.full_id : "#{item.identifier}-#{item.project.test_procedure_prefix}-#{procedure_id.to_s}"

    full_id
  end

  # Generate procedure ID + description.
  def procedure_id_plus_filename
    result  = "#{full_procedure_id} - "

    if file_name.present?
      result += file_name
    end

    result
  end

  def get_test_case
    return test_cases.first
  end

  def get_high_level_requirement
    result    = nil
    test_case = get_test_case

    if test_case.present?
      result  = test_case.get_high_level_requirement
    end

    return result
  end

  def get_low_level_requirement
    result    = nil
    test_case = get_test_case

    if test_case.present?
      result  = test_case.get_low_level_requirement
    end

    return result
  end

  def get_system_requirement
    result                     = nil
    high_level_requirement     = get_high_level_requirement

    if high_level_requirement.present?
      result                   = high_level_requirement.get_system_requirement
    else
      low_level_requirement = get_low_level_requirement

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

    unless @@test_procedures_path.present?
      local                  = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root                   = local['root']                        if local.present?
      @@test_procedures_path = File.join(root,
                                         'test_procedures',
                                         User.current.organization) if root.present?
    end

    path = @@test_procedures_path
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
      when 'ATTACHMENT'
        result     = self.upload_file if self.upload_file.attached?

      when 'EXTERNAL'
        result     =  URI.parse(self.url_link) if self.url_link.present?

      when 'INSTRUMENTED'
        result     = File.read(self.url_link) if File.readable?(self.url_link)

      when 'PACT'
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
    title                      = "Update of #{I18n.t('misc.test_procedure')} ID: #{self.full_id}, " \
                                 "Version #{self.version}."
    archive.name,              = title
    archive.full_id,           = title
    archive.description        = title
    archive.revision           = "1"
    archive.version            = "1"
    archive.archive_type       = Constants::TEST_PROCEDURE_CHANGE
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

    archive.clone_test_procedure(self, self.project_id, self.item_id, session_id)
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
                                                 'test_procedures',
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
    project                       = Project.find_by(id: project_id)
    item                          = Item.find_by(id: item_id)

    return false unless project.present? && item.present?

    project.test_procedure_prefix = new_prefix
    item.test_procedure_prefix    = new_prefix
    change_record                 = DataChange.save_or_destroy_with_undo_session(project,
                                                                                 'update',
                                                                                 project.id,
                                                                                 'projects',
                                                                                 session_id)

    return false unless change_record.present?

    session_id                    = change_record.session_id

    return false unless DataChange.save_or_destroy_with_undo_session(item,
                                                                     'update',
                                                                     item.id,
                                                                     'items',
                                                                     session_id)

    test_procedures               = TestProcedure.where(project_id:   project_id,
                                                        item_id:      item_id,
                                                        organization: User.current.organization)

    test_procedures.each do |test_procedure|
      if test_procedure.full_id.present?
        next unless test_procedure.full_id.sub!(old_prefix, new_prefix).present?
      else
        test_procedure.full_id    = test_procedure.full_procedure_id
      end

      return false unless DataChange.save_or_destroy_with_undo_session(test_procedure,
                                                                       'update',
                                                                       test_procedure.id,
                                                                       'test_procedures',
                                                                       session_id)
    end if test_procedures.present?

    return true
  end

  def self.renumber(item_id,
                    start      = 1,
                    increment  = 1,
                    prefix     = 'TP-',
                    padding    = 3)
    prefix                           = prefix.sub(/\-$/, '')
    session_id                       = nil
    test_procedures                  = TestProcedure.where(item_id: item_id,
                                                          organization: User.current.organization).order(:procedure_id)
    maximum_procedure_id             = TestProcedure.where(item_id:      item_id,
                                                           organization: User.current.organization).maximum(:procedure_id)
    maximum_procedure_id            += 1

    test_procedures.each do |test_procedure|
      test_procedure.procedure_id    = start
      test_procedure.full_id         = prefix + sprintf("-%0*d", padding, start)
      existing_record                = TestProcedure.find_by(procedure_id:        start,
                                                             item_id:      item_id,
                                                             organization: User.current.organization)

      if existing_record.present?
        existing_record.procedure_id = maximum_procedure_id
        maximum_procedure_id        += 1
        change_record                = DataChange.save_or_destroy_with_undo_session(existing_record,
                                                                                    'update',
                                                                                    existing_record.id,
                                                                                    'test_procedures', 
                                                                                    session_id)
        session_id                   = change_record.session_id if change_record.present?
      end

      change_record                  = DataChange.save_or_destroy_with_undo_session(test_procedure,
                                                                                   'update',
                                                                                   test_procedure.id,
                                                                                   'test_procedures', 
                                                                                   session_id)
      session_id                     = change_record.session_id if change_record.present?
      start                         += increment
    end if test_procedures.present?
  end

  # CSV file handling
  DEFAULT_HEADERS = %w{id procedure_id full_id file_name url_type url_description url_link version organization item_id project_id created_at updated_at archive_id test_case_associations description soft_delete document_id file_path content_type file_type revision draft_version revision_date upload_date archive_revision archive_version }

  def get_columns(text_only = true, headers = DEFAULT_HEADERS)
    columns     = []

    headers.each do |attribute|
      value     = self[attribute]

      case attribute
        when 'test_case_associations'
          value = Associations.get_associations_as_full_ids('test_cases',
                                                            'test_procedures',
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
        when 'document_id'
          value = Document.docid_from_id(value)
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
        else
          value = Sanitize.fragment(value).gsub('&nbsp;',
                                                ' ').strip if text_only &&
                                                              value.kind_of?(String)
      end

      columns.push(value)
    end

    return columns
  end

  def self.to_csv(item_id, headers = DEFAULT_HEADERS)

    CSV.generate(headers: true) do |csv|
      csv << headers

      test_procedures = TestProcedure.where(item_id:      item_id,
                                  organization: User.current.organization).order(:full_id)

      RequirementsTracing.sort_on_full_id(test_procedures)

      test_procedures.each { |tc| csv << tc.get_columns(true, headers) }
    end
  end

  def self.to_xls(item_id, headers = DEFAULT_HEADERS)
    xls_workbook    = Spreadsheet::Workbook.new
    xls_worksheet   = xls_workbook.create_worksheet
    current_row     = 0

    xls_worksheet.insert_row(current_row, headers)

    current_row    += 1

    test_procedures = TestProcedure.where(item_id:      item_id,
                                          organization: User.current.organization).order(:full_id)

    RequirementsTracing.sort_on_full_id(test_procedures)

    test_procedures.each do |tp|
      xls_worksheet.insert_row(current_row, tp.get_columns(false, headers))

      current_row  += 1
    end

    file            = Tempfile.new('test-procedures')

    xls_workbook.write(file.path)
    file.rewind

    result          = file.read

    file.close
    file.unlink

    return result
  end

  # Import CSV File Routines

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
    result                          = false

    case column_name
      when 'id'
        result                      = true

      when 'project_id'
        self.project_id             = Project.id_from_name(value) unless self.project_id.present?
        result                      = true

      when 'item_id'
        unless self.item_id.present?
          if item_id.present?
            self.item_id    = item_id
          else
            self.item_id    = Item.id_from_identifier(value)
          end
        end
        result              = true

      when 'procedure_id'
        if value =~ /^\d+\.*\d*$/
          self.procedure_id         = value.to_i
          result                    = true
        elsif value.nil?
          result                    = true
        end

      when 'full_id'
        self.full_id                = value
        result                      = true

      when 'file_name'
        self.file_name              = value
        result                      = true

      when 'version'
        if value =~ /^\d+\.*\d*$/
          self.version              = value.to_i
          result                    = true
        elsif value.nil?
          self.version              = value
          result                    = true
        end

      when 'url_type'
        self.url_type               = value
        result                      = true

      when 'url_link'
        self.url_link               = value
        result                      = true

      when 'url_description'
        self.url_description        = value
        result                      = true

      when 'test_case_associations'
        self.test_case_associations = Associations.set_associations_from_full_ids('test_cases',
                                                                                  'test_procedures',
                                                                                  self.item_id,
                                                                                  value,
                                                                                  true)
        result                      = true

      when 'document_id'
        self.document_id            = Document.id_from_docid(value)
        result                      = true

      when 'archive_id'
        self.archive_id             = Archive.id_from_full_id(value)
        result                      = true

      when 'model_file_id'
        self.model_file_id          = ModelFile.id_from_full_id(value)
        result                      = true

      when 'created_at'
        if value.present?
          begin
            self.created_at         = DateTime.parse(value)
            result                  = true
          rescue
            result                  = false
          end
        else
          result                    = true
        end

      when 'updated_at'
        if value.present?
          begin
            self.updated_at         = DateTime.parse(value)
            result                  = true
          rescue
            result                  = false
          end
        else
          result                    = true
        end

      when 'organization'
        result                      = true

      when 'soft_delete'
        self.soft_delete            = if value =~ /^true$/i ||
                                        value =~ /^y(es){0,1}$/i
                                        true
                                      elsif value =~ /^false$/i ||
                                           value =~ /^n[o]{0,1}$/i
                                        false
                                      else
                                        nil
                                      end
        result                      = true

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
  #              :duplicate_test_procedure if the id is a duplicate;
  #              :test_case_associations_changed if the high level requirements associations changed.
  #              :low_level_requirement_associations_changed if the low level requirements associations changed.
  #
  # Description: This imports a row into the Test Procedures.
  # Calls:       find_or_create_test_procedure_by_id, assign_column
  # Notes:       If the test procedure already exists it is replaced otherwise it
  #              is created and added in this procedure if the id doesn't exist it
  #              is one greater than the last test procedure id.
  # History:     06-16-2020 - First Written, PC

  def self.process_row(columns,
                       item             = nil,
                       session_id       = nil,
                       check_download   = [],
                       headers          = DEFAULT_HEADERS)
    result                   = false

    return result unless columns.present?

    test_procedure           = self.find_or_create_test_procedure_by_id(columns,
                                                                        item,
                                                                        headers)

    return result unless test_procedure.present?

    if check_download.include?(:check_duplicates) && test_procedure.id.present?
      return :duplicate_test_procedure
    end

    test_case_associations   = test_procedure.test_case_associations

    columns.each_with_index do |column, index|
      column_name            = if index < headers.length
                                 headers[index]
                               else
                                 nil
                               end

      result                 = test_procedure.assign_column(column_name,
                                                            column,
                                                            item.id)     if column_name.present?

      break unless result
    end

    if check_download.include?(:check_associations)       &&
       (test_case_associations.present?      &&
        (test_procedure.test_case_associations !=
         test_case_associations))
      return :test_case_associations_changed
    end

    if check_download.empty?
      test_procedure.full_id = "TC-#{test_procedure.procedureid}" if !test_procedure.full_id.present? && test_procedure.reqid.present?
      operation              = test_procedure.id.present? ? 'update' : 'create'
      change_record          = DataChange.save_or_destroy_with_undo_session(test_procedure,
                                                                            operation,
                                                                            test_procedure.id,
                                                                            'test_procedures',
                                                                            session_id)

      if change_record.present?
        result               = Associations.build_associations(test_procedure)
        result               = change_record if result
      end
    else
      result                 = true
    end

    return result
  end

  # Import CSV File Routines

  # The normal Usage would be: TestProcedure.from_file('filename.csv', @item)

  # Method:      from_csv_string
  # Parameters:  line a String,
  #              The line from the CSV File
  #
  #              item an optional Item (default: default from @item),
  #              The item this test case belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       find_or_create_test_case_by_id, assign_column
  # Notes:       If the Test Casealready exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Test Caseid.
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
    rescue e
      message   = "Cannot parse CSV.\nError: #{e.message}.\nLine:  '#{line}'"

      item.errors.add(:name, :blank, message: message)  if item.present?

      return result
    end

    return :skip if columns.empty? # skip empty lines

    result      = process_row(columns, item, session_id, check_download,
                              headers)

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
    columns                = []
    result                 = nil
    session_id             = nil
    xlsx_workbook          = Roo::Excelx.new(input_filename)

    xlsx_workbook.sheets.each do |xlsx_worksheet|
      first_row            = xlsx_workbook.first_row(xlsx_worksheet)
      last_row             = xlsx_workbook.last_row(xlsx_worksheet)

      next if first_row.nil? || last_row.nil?

      if file_has_header
        found              = false

        while (first_row < last_row) && !found
          columns          = xlsx_workbook.row(first_row, xlsx_worksheet)

          columns.each do |cell|
            next unless cell.present?

            found          = (cell.to_s == headers[0])

            if found
              headers      = []

              columns.each do |column|
                column     = '' unless column.present?

                headers.push(column.to_s)
              end unless columns.nil?

              break
            end
          end unless columns.nil?

          first_row       += 1

          break if found
        end
      else
        current_row        = first_row

        while (current_row < last_row) && !found
          columns          = xlsx_workbook.row(current_row, xlsx_worksheet)

          columns.each do |cell|
            next unless cell.present?

            found          = (cell.to_s == headers[0])

            if found
              first_row    = current_row + 1

              break
            end
          end unless columns.nil?

          current_row     += 1

          break if found
        end
      end

      for row in first_row...(last_row + 1) do
        columns            = []
        row_columns        = xlsx_workbook.row(row, xlsx_worksheet)

        row_columns.each do |cell|
          if cell.nil?
            columns.push(nil)
          else
            columns.push(cell.to_s)
          end
        end unless columns.nil?

        test_procedure     = self.find_or_create_test_procedure_by_id(columns, item,
                                                                      headers)

        return result unless test_procedure.present?

        result             = process_row(columns, item, session_id,
                                         check_download, headers)

        if result.kind_of?(ChangeSession)
          session_id       = result.session_id
        elsif (result != :skip) && (result != true) 
          return result
        end
      end
    end

    result                 = true

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

        test_procedure                 = self.find_or_create_test_procedure_by_id(columns, item,
                                                                                  headers)

        return result unless test_procedure.present?

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
    result             = false
    first_line         = true
    session_id         = nil

    if File.readable?(filename)
      CSV.foreach(filename) do |row|
        if first_line && (file_has_header || (row[0] =~ /\s*(id|procedure_id)\s*/))
          headers      = row.map() { |column|  (column =~ /\s*([A-Za-z_ ]+)\s*/) ? $1 : column }
        else
          result       = self.from_csv_string(row, item, check_download, headers,
                                              session_id)

          if result.kind_of?(ChangeSession)
            session_id = result.session_id
          elsif (result != :skip) && (result != true) 
            return result
          end
        end

        first_line     = false
      end

      result = true
    else
      message          = "The file '#{filename}' is not readable or does not exist."

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
    result         = false
    session_id     = nil

    while (line = io.readline)
      result       = self.from_csv_string(line, item, check_download, headers,
                                          session_id)

      if result.kind_of?(ChangeSession)
        session_id = result.session_id
      elsif (result != :skip) && (result != true) 
        return result
      end
    end

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
    result     = false

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

  # Method:      generate_test_procedures
  # Parameters:  files an array of Strings,
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #              
  #              headers an optional array of strings (default: DEFAULT_HEADERS)
  #
  # Return:      True if they were generated successfully false otherwise.
  # Description: This generates test procedure items from a list of file names.
  # Calls:       find_or_create_requirement_by_id
  # Notes:       
  # History:     09-02-2019 - First Written, PC

  def self.generate_test_procedures(files,
                                    item    = @item,
                                    headers = DEFAULT_HEADERS)
    result                        = false
    filename_at                   = headers.find_index('file_name')
    url_type_at                   = headers.find_index('url_type')
    url_link_at                   = headers.find_index('url_link')
    url_description_at            = headers.find_index('url_description')
    session_id                    = nil

    return result unless filename_at.present?

    files.each do |file|
      description                 = ''
      filename                    = ''
      url                         = ''

      if file.index('|') > 0
        filename,
        url                       = file.split('|')
      else
        filename                  = file
      end

      if url =~ /^.*\/(.+)$/
        description               = $1
      else
        description               = url
      end

      columns                     = []
      columns[filename_at]        = filename
      columns[url_type_at]        = 'EXTERNAL'  if url_type_at.present?
      columns[url_link_at]        = url         if url_link_at.present?
      columns[url_description_at] = description if url_description_at.present?
      test_procedure                 = self.find_or_create_test_procedure_by_id(columns,
                                                                                item)

      if test_procedure.present?
        columns.each_with_index do |value, index|
          column_name             = if index < headers.length
                                      headers[index]
                                    else
                                      nil
                                    end

          result                  = test_procedure.assign_column(column_name,
                                                              value,
                                                              item.id) if column_name.present?

          break unless result
        end
      end

      change_session              = DataChange.save_or_destroy_with_undo_session(test_procedure,
                                                                                 test_procedure.id.present? ? 'update' : 'create',
                                                                                 test_procedure.id, 'test_procedures', 
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

private
  # Method:      find_or_create_requirement_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the procedure_id).
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

  def self.find_or_create_test_procedure_by_id(columns,
                                               item    = @item,
                                               headers = DEFAULT_HEADERS)
    id_at                    = headers.find_index('procedure_id')
    id                       = columns[id_at].to_i if id_at.present? &&
                                                      columns[id_at] =~ /^\d+\.*\d*$/
    project                  = Project.find(item.project_id)

    if id.present?
      test_procedure = TestProcedure.find_by(procedure_id: id, item_id: item.id)
    else
      last_id             = nil
      test_procedures = TestProcedure.where(item_id: item.id, organization: User.current.organization).order("procedure_id")

      test_procedures.each do |requirement|
        if last_id.present? && (last_id != (requirement.procedure_id - 1)) # we found a hole.
          id = last_id + 1

          break;
        end

        last_id = requirement.procedure_id
      end

      id = if id.present?
             id
           elsif last_id.present?
             last_id + 1
           else
             1
           end
    end

    unless test_procedure.present?
      item.tp_count               = if item.tp_count.present?
                                      item.tp_count + 1
                                    else
                                      1
                                    end
      test_procedure              = TestProcedure.new()
      test_procedure.project_id   = project.id
      test_procedure.item_id      = item.id
      test_procedure.procedure_id = id
    end

    return test_procedure
  end
end
