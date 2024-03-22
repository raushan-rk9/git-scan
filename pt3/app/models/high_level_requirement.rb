class HighLevelRequirement < OrganizationRecord
  # Associate projects and items with this record.
  # Without optional: true, the form doesn't pick up the id.
  # May be a bug, in the future, should test without optional: true.
  belongs_to :item,       optional: true
  belongs_to :project,    optional: true
  belongs_to :document,   optional: true
  belongs_to :model_file, optional: true

  # Associate HLRs with System Requirements
  has_and_belongs_to_many :system_requirements,     -> { distinct }, join_table: "sysreq_hlrs"

  # Associate HLRs with HLRs
  has_and_belongs_to_many :high_level_requirements, -> { distinct },
                                                    join_table:              "hlr_hlrs",
                                                    foreign_key:             'high_level_requirement_id',
                                                    association_foreign_key: 'referenced_high_level_requirement_id'

  # Associate LLRs with HLRs
  has_and_belongs_to_many :low_level_requirements,  -> { distinct }, join_table: "hlr_llrs"

  # Associate MDs with hLRs
  has_and_belongs_to_many :module_descriptions,     -> { distinct }, join_table: "hlr_mds"

  # Associate SCs with HLRs
  has_and_belongs_to_many :source_codes,            -> { distinct }, join_table: "hlr_scs"

  # Associate TCs with HLRs
  has_and_belongs_to_many :test_cases,              -> { distinct }, join_table: "hlr_tcs"

  has_one_attached :image, dependent: false
  # Validations
  validates :reqid,       presence: true, allow_blank: false
  validates :project_id,  presence: true, allow_blank: false
  validates :item_id,     presence: true, allow_blank: false
  validates :full_id,     presence: true, allow_blank: false
  validates :description, presence: true, allow_blank: false

  # Allow only images as attachments
  # Do not validate if image is not attached.
  validates :image, file_size: { less_than_or_equal_to: 10.megabytes }, if: proc { image.attached? }
  validates :image, file_content_type: { allow: ["image/jpeg", "image/gif", "image/png"] }, if: proc { image.attached? }

  serialize :verification_method, Array

  # Instantiate variables not in database
  attr_accessor :remove_image
  attr_accessor :selected
  attr_accessor :full_id_prefix
  attr_accessor :upload_file
  attr_accessor :archive_type
  attr_accessor :archive_revision
  attr_accessor :archive_version

  # Generate Long ID, full_id + reqid + item_id
  def long_id
    item_id   = if self.item_id.present?
                item = Item.find_by(id: self.item_id)

                item.present? ? item.identifier : ''
              else
                ''
              end
    object_id = if self.reqid.present?
                  self.reqid.to_s
                else
                  ''
                end

    result    = self.full_id.present? ? self.full_id + ':' : ''
    result   += object_id + ':'
    result   += item_id

    return result
  end

  # Generate Item identifier + reqid
  def fullreqid
    full_id =  self.full_id.present? ?  self.full_id : self.long_id

    full_id
  end

  # Generate requirement ID + description.
  def reqplusdescription
    "#{fullreqid.to_s}: #{description}"
  end

  def get_system_requirement
    return system_requirements.first
  end

  def add_model_document(file, session_id)
    model_file = if self.model_file_id.present? && (self.model_file_id >= 0)
                 ModelFile.replace_model_file_file(self.model_file_id, file,
                                                   session_id)
               else
                 ModelFile.add_model_file(self, file, self.item_id, session_id)
               end

    return model_file
  end

public
  def self.rename_prefix(project_id, item_id, old_prefix, new_prefix,
                         session_id = nil)
    return true unless project_id.present? &&
                       item_id.present?    &&
                       old_prefix.present? &&
                       new_prefix.present? &&
                       (old_prefix != new_prefix)
    project                                = Project.find_by(id: project_id)
    item                                   = Item.find_by(id: item_id)

    return false unless project.present? && item.present?

    project.high_level_requirements_prefix = new_prefix
    item.high_level_requirements_prefix    = new_prefix
    change_record                          = DataChange.save_or_destroy_with_undo_session(project,
                                                                                          'update',
                                                                                          project.id,
                                                                                          'projects',
                                                                                          session_id)

    return false unless change_record.present?

    session_id                             = change_record.session_id
    
    return false unless DataChange.save_or_destroy_with_undo_session(item,
                                                                     'update',
                                                                     item.id,
                                                                     'items',
                                                                     session_id)

    high_level_requirements                = HighLevelRequirement.where(project_id:   project_id,
                                                                        item_id:      item_id,
                                                                        organization: User.current.organization)

    high_level_requirements.each do |high_level_requirement|
      if high_level_requirement.full_id.present?
        next unless high_level_requirement.full_id.sub!(old_prefix,
                                                        new_prefix).present?
      else
        high_level_requirement.full_id     = high_level_requirement.fullreqid
      end

      return false unless DataChange.save_or_destroy_with_undo_session(high_level_requirement,
                                                                       'update',
                                                                       high_level_requirement.id,
                                                                       'high_level_requirements',
                                                                       session_id)
    end if high_level_requirements.present?

    return true
  end

  def self.renumber(item_id,
                    start      = 1,
                    increment  = 1,
                    prefix     = 'SYS-',
                    padding    = 3)
    prefix                           = prefix.sub(/\-$/, '')
    session_id                       = nil
    high_level_requirements          = HighLevelRequirement.where(item_id:      item_id,
                                                                  organization: User.current.organization).order(:reqid)
    maximum_reqid                    = HighLevelRequirement.where(item_id:      item_id,
                                                                  organization: User.current.organization).maximum(:reqid)
    maximum_reqid                   += 1

    high_level_requirements.each do |high_level_requirement|
      high_level_requirement.reqid   = start
      high_level_requirement.full_id = prefix + sprintf("-%0*d", padding, start)
      existing_record                = HighLevelRequirement.find_by(reqid:        start,
                                                                    item_id:      item_id,
                                                                    organization: User.current.organization)

      if existing_record.present?
        existing_record.reqid        = maximum_reqid
        maximum_reqid               += 1
        change_record                = DataChange.save_or_destroy_with_undo_session(existing_record,
                                                                                    'update',
                                                                                    existing_record.id,
                                                                                    'high_level_requirements', 
                                                                                    session_id)
        session_id                   = change_record.session_id if change_record.present?
      end

      change_record                  = DataChange.save_or_destroy_with_undo_session(high_level_requirement,
                                                                                    'update',
                                                                                    high_level_requirement.id,
                                                                                    'high_level_requirements', 
                                                                                    session_id)
      session_id                     = change_record.session_id if change_record.present?
      start                         += increment
    end if high_level_requirements.present?
  end

  # file handling
  DEFAULT_HEADERS = %w{id reqid full_id description category safety robustness derived testmethod version item_id project_id system_requirement_associations derived_justification created_at updated_at organization verification_method archive_id high_level_requirement_associations soft_delete document_id model_file_id archive_revision archive_version}

  def get_columns(text_only = true, headers = DEFAULT_HEADERS)
    columns     = []

    headers.each do |attribute|
      value     = self[attribute]

      case attribute
        when 'system_requirement_associations'
          value = Associations.get_associations_as_full_ids('system_requirements',
                                                            'high_level_requirements',
                                                            project_id,
                                                            value,
                                                            true)
        when 'high_level_requirement_associations'
          value = Associations.get_associations_as_full_ids('high_level_requirements',
                                                            'high_level_requirements',
                                                            project_id,
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
        when 'model_file_id'
          value = ModelFile.full_id_from_id(value)
        when 'document_id'
          value = Document.docid_from_id(value)
        when 'verification_method'
          value = value.join(',')
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

  # Create csv
  def self.to_csv(item_id, headers = DEFAULT_HEADERS)
    CSV.generate(headers: true) do |csv|
      csv << headers
      high_level_requirements = HighLevelRequirement.where(item_id:      item_id,
                                                           organization: User.current.organization).order(:full_id)

      RequirementsTracing.sort_on_full_id(high_level_requirements)

      high_level_requirements.each { |hlr| csv << hlr.get_columns(true, headers) }
    end
  end

  def self.to_xls(item_id, headers = DEFAULT_HEADERS)
    xls_workbook  = Spreadsheet::Workbook.new
    xls_worksheet = xls_workbook.create_worksheet
    current_row   = 0

    xls_worksheet.insert_row(current_row, headers)

    current_row += 1

    high_level_requirements = HighLevelRequirement.where(item_id:   item_id,
                                                         organization: User.current.organization).order(:full_id)

    RequirementsTracing.sort_on_full_id(high_level_requirements)

    high_level_requirements.each do |hlr|
      xls_worksheet.insert_row(current_row, hlr.get_columns(false, headers))

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

  # Import CSV File Routines

  # The normal Usage would be: HighLevelRequirement.from_file('filename.csv'
  #                                                           @item)

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
        result = self.from_csv_filename(input, item, check_download, headers,
                                        file_has_header)
      elsif input =~ /^.+\.xlsx$/i # If it's an xlsx file
        result = self.from_xlsx_filename(input, item, check_download, headers,
                                         file_has_header)
      elsif input =~ /^.+\.xls$/i # If it's an xls file
        result = self.from_xls_filename(input, item, check_download, headers,
                                        file_has_header)
      else                     # If is a line from a csv file
        result = self.from_csv_string(input, item, check_download, headers)
      end
    elsif input.kind_of?(IO)    # If it's an input stream
      result = self.from_csv_io(input, item, check_download, headers)
    end

    return result
  end

  # Method:      assign_column
  # Parameters:  column_name a String,
  #              The name of the column to be assigned.
  #
  #              value an object,
  #              The value to set the column to.
  #              
  # Return:      A Boolean, true if the value was assigned false otherwise.
  # Description: Assigns a valiue to a specic value in the HighLevelRequirement
  # Calls:       None
  # Notes:       
  # History:     06-10-2019 - First Written, PC

  def assign_column(column_name, value, item_id)
    result                  = false

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
      when 'reqid'
        if value =~ /^\d+\.*\d*$/
          self.reqid        = value.to_i
          result            = true
        elsif value.nil?
          result            = true
        end
      when 'full_id'
        self.full_id        = value
        result              = true
      when 'description'
        self.description    = value
        result              = true
      when 'category'
        self.category       = value
        result              = true
      when 'verification_method'
        self.verification_method = value.split(',') if value.present?
        result                   = true
      when 'testmethod'
        self.testmethod     = value
        result              = true
      when 'derived'
        self.derived        = if value =~ /^true$/i ||
                                value =~ /^y(es){0,1}$/i
                                true
                              elsif value =~ /^false$/i ||
                                   value =~ /^n[o]{0,1}$/i
                                false
                              else
                                nil
                              end
        result              = true
      when 'derived_justification'
        self.derived_justification = value
        result                     = true
      when 'safety'
        self.safety         = if value =~ /^true$/i ||
                                value =~ /^y(es){0,1}$/i
                                true
                              elsif value =~ /^false$/i ||
                                   value =~ /^n[o]{0,1}$/i
                                false
                              else
                                nil
                              end
        result              = true
      when 'robustness'
        self.robustness     = if value =~ /^true$/i ||
                                value =~ /^y(es){0,1}$/i
                                true
                              elsif value =~ /^false$/i ||
                                   value =~ /^n[o]{0,1}$/i
                                false
                              else
                                nil
                              end
        result              = true
      when 'version'
        if value =~ /^\d+\.*\d*$/
          self.version      = value.to_i
          result            = true
        elsif value.nil?
          self.version      = value
          result            = true
        end
      when 'system_requirement_associations'
        self.system_requirement_associations = Associations.set_associations_from_full_ids('system_requirements',
                                                                                           'high_level_requirements',
                                                                                           self.project_id,
                                                                                           value,
                                                                                           true)
        result                               = true
      when 'high_level_requirement_associations'
        self.high_level_requirement_associations = Associations.set_associations_from_full_ids('high_level_requirements',
                                                                                               'high_level_requirements',
                                                                                               self.project_id,
                                                                                               value,
                                                                                               true)
        result                                   = true
      when 'document_id'
        self.document_id    = Document.id_from_docid(value)
        result              = true
      when 'archive_id'
        self.archive_id     = Archive.id_from_full_id(value)
        result              = true
      when 'model_file_id'
        self.model_file_id  = ModelFile.id_from_full_id(value)
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
      when 'soft_delete'
        self.soft_delete    = if value =~ /^true$/i ||
                                value =~ /^y(es){0,1}$/i
                                true
                              elsif value =~ /^false$/i ||
                                   value =~ /^n[o]{0,1}$/i
                                false
                              else
                                nil
                              end
        result              = true
      when 'archive_revision'
        self.archive_revision = value
        result                = true
      when 'archive_version'
        self.archive_version = value.to_f if value.present?
        result                = true
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
  #                  :high_level_requirement_associations_changed
  #              headers an optional array of strings (default: DEFAULT_HEADERS);
  #              the headers for the file.
  #
  # Return:      DataChange if it was processed successfully and saved;
  #              true if echecking and no errors;
  #              :duplicate_high_level_requirement if the id is a duplicate;
  #              :system_requirement_associations_changed if the system requirements associations changed;
  #              :high_level_requirement_associations_changed if the high level requirements associations changed.
  #
  # Description: This imports a row into the High Level Requiremens.
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-16-2020 - First Written, PC

  def self.process_row(columns,
                       item             = nil,
                       session_id       = nil,
                       check_download   = [],
                       headers          = DEFAULT_HEADERS)
    result                              = false

    return result unless columns.present?

    high_level_requirement              = self.find_or_create_high_level_requirement_by_id(columns,
                                                                                           item,
                                                                                           headers)

    return result unless high_level_requirement.present?

    if check_download.include?(:check_duplicates) && high_level_requirement.id.present?
      return :duplicate_high_level_requirement
    end

    system_requirement_associations     = high_level_requirement.system_requirement_associations
    high_level_requirement_associations = high_level_requirement.high_level_requirement_associations

    columns.each_with_index do |column, index|
      column_name                       = if index < headers.length
                                            headers[index]
                                          else
                                            nil
                                          end
      result                            = high_level_requirement.assign_column(column_name,
                                                                               column,
                                                                               item.id)     if column_name.present?

      break unless result
    end

    if check_download.include?(:check_associations)             &&
       (system_requirement_associations.present?                &&
        (high_level_requirement.system_requirement_associations !=
         system_requirement_associations))
      return :system_requirement_associations_changed
    end

    if check_download.include?(:check_associations)                 &&
       (high_level_requirement_associations.present?                &&
        (high_level_requirement.high_level_requirement_associations !=
         high_level_requirement_associations))
      return :high_level_requirement_associations_changed
    end

    if check_download.empty?
      high_level_requirement.full_id    = "HLR-#{high_level_requirement.reqid}" if !high_level_requirement.full_id.present? && high_level_requirement.reqid.present?
      operation                         = high_level_requirement.id.present? ? 'update' : 'create'
      change_record                     = DataChange.save_or_destroy_with_undo_session(high_level_requirement,
                                                                                       operation,
                                                                                       high_level_requirement.id,
                                                                                       'high_level_requirements',
                                                                                       session_id)

      if change_record.present?
        result                          = Associations.build_associations(high_level_requirement)
        result                          = change_record if result
      end
    else
      result                            = true
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
                              item,
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

        result          = process_row(columns, item, session_id, check_download,
                                      headers)

        if result.kind_of?(ChangeSession)
          session_id    = result.session_id
        elsif result != true
          return result
        end
      end
    end

    result              = true

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
        if first_line && (file_has_header || (row[0] =~ /\s*(id|reqid)\s*/))
          headers      = row.map() { |column|  (column =~ /\s*([A-Za-z_ ]+)\s*/) ? $1 : column }
        else
          result       = self.from_csv_string(row, item, check_download,
                                              headers, session_id)

          if result.kind_of?(ChangeSession)
            session_id = result.session_id
          elsif (result != :skip) && (result != true) 
            return result
          end
        end

        first_line = false
      end

      result = true
    else
      message = "The file '#{filename}' is not readable or does not exist."

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
                       item            = @item,
                       check_download  = [],
                       headers         = DEFAULT_HEADERS)
    result     = false
    session_id = nil

    while (line = io.readline)
      result   = self.from_csv_string(line, item, check_download, headers,
                                      session_id)

      if result.kind_of?(DataChange)
        session_id = result.session_id
      elsif (result != :skip) && (result != true) 
        return result
      end
    end

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
  # Description: This imports data from an XLS file into the High Level Requiremens.
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

        result                         = process_row(columns, item, session_id,
                                                     check_download, headers)

        if result.kind_of?(ChangeSession)
          session_id    = result.session_id
        elsif (result != :skip) && (result != true) 
          return result
        end
      end
    end

    result                             = true

    return result
  end

private
  # Method:      find_or_create_requirement_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the reqid).
  #
  #              item an optional Item (default: default from @item),
  #              The item this requirement belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      A High Level Requirement Object.
  # Description: Finds or Creates a High Level Requirement Object by the ID in the line.
  # Calls:       None
  # Notes:       If the requirement already exists it is returned otherwise a
  #              a new one is created. In this case, if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     06-10-2019 - First Written, PC

  def self.find_or_create_high_level_requirement_by_id(columns,
                                                       item    = @item,
                                                       headers = DEFAULT_HEADERS)
    id_at                    = headers.find_index('reqid')
    id                       = columns[id_at].to_i if id_at.present? &&
                                                      columns[id_at] =~ /^\d+\.*\d*$/
    project                  = Project.find(item.project_id)

    if id.present?
      high_level_requirement = HighLevelRequirement.find_by(reqid:   id,
                                                            item_id: item.id)
    else
      last_id                 = nil
      high_level_requirements = HighLevelRequirement.where(item_id:  item.id, organization: User.current.organization).order("reqid")

      high_level_requirements.each do |requirement|
        if last_id.present? && (last_id != (requirement.reqid - 1)) # we found a hole.
          id = last_id + 1

          break;
        end

        last_id = requirement.reqid
      end

      id = if id.present?
             id
           elsif last_id.present?
             last_id + 1
           else
             1
           end
    end

    unless high_level_requirement.present?
      item.hlr_count                   += 1
      high_level_requirement            = HighLevelRequirement.new()
      high_level_requirement.project_id = project.id
      high_level_requirement.item_id    = item.id
      high_level_requirement.reqid      = id
    end

    return high_level_requirement
  end
end
