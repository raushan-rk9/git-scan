class ProblemReport < OrganizationRecord
  has_many :problem_report_attachments, dependent: :destroy

  # Instantiate variables not in database
  attr_accessor :prh_action

  # Establish relationships
  belongs_to :project, optional: true
  belongs_to :item, optional: true
  # Use has_many to in order to put foreign key in pr_history table.
  # https://stackoverflow.com/a/861899
  has_many :problem_report_history, inverse_of: :problem_report, dependent: :destroy
  accepts_nested_attributes_for :problem_report_history, allow_destroy: true
  # Access file attachments from prs
  has_many :problem_report_attachment, inverse_of: :problem_report, dependent: :destroy
  accepts_nested_attributes_for :problem_report_attachment, allow_destroy: true

  # Validations
  validates :project_id, presence: true, allow_blank: false
  validates :prid,       presence: true, allow_blank: false
  validates :title,      presence: true, allow_blank: false
#  validates :prh_action, presence: true

  #serializations
  serialize :referenced_artifacts, Hash

  # Instantiate variables not in database
  attr_accessor :attachment_file
  attr_accessor :archive_revision
  attr_accessor :archive_version
  attr_accessor :recipients
  attr_accessor :cc_list
  attr_accessor :comment

  # Generate Item identifier + id
  def fullprid
    "#{project.identifier}-PR-#{prid.to_s}"
  end

  # Generate Item identifier + id
  def fullprwithdesc
    "#{fullprid}: #{description}"
  end

  # Generate Item identifier + id
  def fullpr_with_title
    "#{fullprid}: #{title}"
  end

  # Generate Item identifier + id
  def self.get_full_title(problem_id)
    result         = ''
    problem_report = ProblemReport.find_by(id: problem_id)
    result         = problem_report.fullpr_with_title if problem_report.present?

    return result
  end

  # CSV file handling
  DEFAULT_HEADERS = %w{item_id prid dateopened status openedby title product criticality source discipline_assigned assignedto target_date close_date description problemfoundin correctiveaction fixed_in verification feedback notes meeting_id safetyrelated datemodified archive_id referenced_artifacts}

  # Create csv
  def self.to_csv(project_id)
    attributes        = DEFAULT_HEADERS

    CSV.generate(headers: true) do |csv|
      csv << attributes

      problem_reports = ProblemReport.where(project_id:   project_id,
                                            organization: User.current.organization).order(:prid)
      columns         = []

      problem_reports.each do |problem_report|
        columns       = []

        attributes.each do |attribute|
          value       = if attribute == 'referenced_artifacts'
                          problem_report[attribute].to_json
                        else
                          Sanitize.fragment(problem_report[attribute]).gsub('&nbsp;',
                                                                            ' ').strip
                        end
          columns.push(value)
        end

        csv << columns
      end
    end
  end

  def self.to_xls(project_id)
    attributes      = DEFAULT_HEADERS
    xls_workbook    = Spreadsheet::Workbook.new
    xls_worksheet   = xls_workbook.create_worksheet
    current_row     = 0

    xls_worksheet.insert_row(current_row, attributes)

    current_row    += 1

    problem_reports = ProblemReport.where(project_id:   project_id,
                                          organization: User.current.organization).order(:prid)

    problem_reports.each do |problem_report|
      columns       = []

      attributes.each do |attribute|
        value       = if attribute == 'referenced_artifacts'
                        problem_report[attribute].to_json
                      else
                        Sanitize.fragment(problem_report[attribute]).gsub('&nbsp;',
                                                                          ' ').strip
                      end

        columns.push(value)
      end

      xls_worksheet.insert_row(current_row, columns)

      current_row  += 1
    end

    file            = Tempfile.new('problem_reports')

    xls_workbook.write(file.path)
    file.rewind

    result          = file.read

    file.close
    file.unlink

    return result
  end

  # Import CSV File Routines

  # The normal Usage would be: ProblemReport.from_file('filename.csv', project)

  # Method:      from_csv
  # Parameters:  input a String or IO,
  #              if a string it's either a filename or a line from a file.
  #              If it's an IO it's an opened input stream.
  #
  #              project an optional Project (default: default from @project),
  #              The project this Problem Report belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #
  #              file_has_header an optional boolean (default: false),
  #              If true the CSV file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_file, from_csv_io, or from_csv_string
  # Notes:       If the Problem Report already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Problem Report id.
  # History:     06-10-2019 - First Written, PC

  def self.from_file(input,
                     project         = @project,
                     check_download  = [],
                     headers         = DEFAULT_HEADERS,
                     file_has_header = false)
    result     = false

    if input.kind_of?(String)
      if input =~ /^.+\.csv$/i # If it's a csv filename
        result = self.from_csv_filename(input,
                                        project,
                                        check_download,
                                        headers,
                                        file_has_header)
      elsif input =~ /^.+\.xlsx$/i # If it's an xlsx file
        result = self.from_xlsx_filename(input,
                                         project,
                                         check_download,
                                         headers,
                                         file_has_header)
      elsif input =~ /^.+\.xls$/i # If it's an xls file
        result = self.from_xls_filename(input,
                                        project,
                                        check_download,
                                        headers,
                                        file_has_header)
      else                     # If is a line from a csv file
        result = self.from_csv_string(input, project, check_download, headers)
      end
    elsif input.kind_of?(IO)    # If it's an input stream
      result   = self.from_csv_io(input, project,  check_download, headers)
    end

    return result
  end

  # Method:      from_xlsx_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              project an optional Project (default: default from @project),
  #              The project this Problem Report belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: false),
  #              If true the XLSX file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLSX file into the System Requiremens.
  # Calls:       find_or_create_problem_report_by_id, assign_column
  # Notes:       If the Problem Report already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Problem Report id.
  # History:     09-23-2019 - First Written, PC

  def self.from_xlsx_filename(input_filename,
                              project         = @project,
                              check_download  = [],
                              headers         = DEFAULT_HEADERS,
                              file_has_header = false)
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

        problem_report     = self.find_or_create_problem_report_by_id(columns,
                                                                      project,
                                                                      headers)

        return result unless problem_report.present?

        if check_download.include?(:check_duplicates) && problem_report.id.present?
          return :duplicate_problem_report
        end

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name    = if index < headers.length
                               headers[index]
                             else
                               nil
                             end

            if column_name.present?
              result       = problem_report.assign_column(column_name, column,
                                                          project.id)
            end

            break unless result
          end

          if check_download.empty?
            operation       = problem_report.id.present? ? 'update' : 'create'
            change_record   = DataChange.save_or_destroy_with_undo_session(problem_report,
                                                                           operation,
                                                                           problem_report.id,
                                                                           'problem_reports', 
                                                                           session_id)
            session_id      = change_record.session_id if change_record.present?

            return result unless session_id.present?
          end
        end
      end
    end

    result                = true

    return result
  end

  # Method:      from_xls_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              project an optional project (default: default from @project),
  #              The project this Problem Report belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: false),
  #              If true the XLS file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLS file into the Problem Cases.
  # Calls:       find_or_create_problem_report_by_id, assign_column
  # Notes:       If the Problem Report already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Problem Report id.
  # History:     09-23-2019 - First Written, PC

  def self.from_xls_filename(input_filename,
                             project         = @project,
                             check_download  = [],
                             headers         = DEFAULT_HEADERS,
                             file_has_header = false)
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

        problem_report                 = self.find_or_create_problem_report_by_id(columns,
                                                                                  project,
                                                                                  headers)

        return result unless problem_report.present?

        if check_download.include?(:check_duplicates) && problem_report.id.present?
          return :duplicate_problem_report
        end

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name                = if index < headers.length
                                           headers[index]
                                         else
                                           nil
                                         end

            if column_name.present?
              result                   = problem_report.assign_column(column_name,
                                                                      column,
                                                                      project.id)
            end

            break unless result
          end

          if check_download.empty?
            operation       = problem_report.id.present? ? 'update' : 'create'
            change_record   = DataChange.save_or_destroy_with_undo_session(problem_report,
                                                                           operation,
                                                                           problem_report.id,
                                                                           'problem_reports', 
                                                                           session_id)
            session_id      = change_record.session_id if change_record.present?

            return result unless session_id.present?
          end
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
  #              project an optional project (default: default from @project),
  #              The project this Problem Report belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  #              file_has_header an optional boolean (default: false),
  #              If true the CSV file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the Problem Report already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Problem Report id.
  # History:     06-10-2019 - First Written, PC

  def self.from_csv_filename(filename,
                             project         = @project,
                             check_download  = [],
                             headers         = DEFAULT_HEADERS,
                             file_has_header = false)
    result               = false
    first_line           = true
    session_id           = nil

    if File.readable?(filename)
      CSV.foreach(filename) do |row|
        if first_line && (file_has_header || (row[0] =~ /\s*report_id\s*/))
          headers        = row.map() { |column|  (column =~ /\s*([A-Za-z_ ]+)\s*/) ? $1 : column }
        else
          change_session = self.from_csv_string(row, project, check_download,
                                                headers, session_id)

          return :duplicate_problem_report              if change_session == :duplicate_problem_report

          next if change_session == :skip

          return result unless change_session.present?

          session_id     = change_session.session_id    if change_session.instance_of?(ChangeSession)
        end

        first_line       = false
      end

      result             = true
    else
      message            = "The file '#{filename}' is not readable or does not exist."

      @project.errors.add(:name, :blank, message: message) if @project.present?
      project.errors.add(:name, :blank, message: message)  if project.present?
    end

    return result
  end

  # Method:      from_csv_io
  # Parameters:  file an IO,
  #              The opened input stream.
  #
  #              project an optional project (default: default from @project),
  #              The project this Problem Report belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the Problem Report already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Problem Report id.
  # History:     06-10-2019 - First Written, PC

  def self.from_csv_io(file,
                       project        = @project,
                       check_download = [],
                       headers        = DEFAULT_HEADERS)
    result       = false
    session_id   = nil

    while (line = io.readline)
      result     = self.from_csv_string(line, project, check_download, headers,
                                        session_id)

      return :duplicate_problem_report if result == :duplicate_problem_report

      next if result == :skip

      session_id = result.session_id if result.instance_of?(ChangeSession)

      break unless result
    end

    return result
  end

  # Method:      from_csv_string
  # Parameters:  line a String,
  #              The line from the CSV File
  #
  #              project an optional project (default: default from @project),
  #              The project this Problem Report belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       find_or_create_problem_report_by_id, assign_column
  # Notes:       If the Problem Report already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last Problem Report id.
  # History:     06-10-2019 - First Written, PC

  def self.from_csv_string(line,
                           project        = @project,
                           check_download = [],
                           headers        = DEFAULT_HEADERS,
                           session_id     = nil)
    result          = false
    columns         = []

    begin
      if line.kind_of?(String)
        columns     = CSV.parse_line(line)
      elsif line.kind_of?(Array)
        columns     = line
      end
    rescue e
      message       = "Cannot parse CSV.\nError: #{e.message}.\nLine:  '#{line}'"

      @project.errors.add(:name, :blank, message: message) if @project.present?
      project.errors.add(:name, :blank, message: message)  if project.present?

      return result
    end

    return true if columns.empty? || columns[0] == 'item_id' # skip empty lines

    problem_report  = self.find_or_create_problem_report_by_id(columns, project,
                                                               headers)

    if problem_report.present?
        if check_download.include?(:check_duplicates) && problem_report.id.present?
          return :duplicate_problem_report
        end

      columns.each_with_index do |value, index|
        column_name = if index < headers.length
                        headers[index]
                      else
                        nil
                      end

        result      = problem_report.assign_column(column_name,
                                                   value,
                                                   project.id) if column_name.present?

        break unless result
      end

      if check_download.empty?
        result      = DataChange.save_or_destroy_with_undo_session(problem_report,
                                                                   problem_report.id.present? ? 'update' : 'create',
                                                                   problem_report.id, 'problem_reports', 
                                                                   session_id)
      end
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
  # Return:      A Boolean, ture if the value was assigned false otherwise.
  # Description: Assignes a valiue to a specic value in the Problem Report
  # Calls:       None
  # Notes:       
  # History:     06-10-2019 - First Written, PC

  def assign_column(column_name, value, project_id)
    result                        = false

    case column_name
      when 'id', 'archive_id'
        result                    = true

      when 'item_id'
        if value.present? && value != "0"
          if value =~ /^\d+$/
            self.item_id          = value.to_i
          else
            self.item_id          = Item.id_from_identifier(value)
          end
        else
          self.item_id            = nil
        end

        result                    = true

      when 'project_id'
        self.project_id           = Project.id_from_name(value) unless self.project_id.present?
        result                    = true

      when 'prid'
        if value =~ /^\d+\.*\d*$/
          self.prid               = value.to_i
          result                  = true
        elsif value.nil?
          result                  = true
        end

      when 'dateopened'
        if value.present?
          begin
            self.dateopened       = DateTime.parse(value)
            result                = true
          rescue
            result                = false
          end
        else
          result                  = true
        end

      when 'status'
        self.status               = value
        result                    = true

      when 'openedby'
        self.openedby             = value
        result                    = true

      when 'title'
        self.title                = value
        result                    = true

      when 'product'
        self.product              = value
        result                    = true

      when 'criticality'
        self.criticality          = value
        result                    = true

      when 'source'
        self.source               = value
        result                    = true

      when 'discipline_assigned'
        self.discipline_assigned  = value
        result                    = true

      when 'assignedto'
        self.assignedto           = value
        result                    = true

      when 'target_date'
        if value.present?
          begin
            self.target_date      = DateTime.parse(value)
            result                = true
          rescue
            result                = false
          end
        else
          result                  = true
        end

      when 'close_date'
        if value.present?
          begin
            self.close_date       = DateTime.parse(value)
            result                = true
          rescue
            result                = false
          end
        else
          result                  = true
        end

      when 'description'
        self.description          = value
        result                    = true

      when 'problemfoundin'
        self.problemfoundin       = value
        result                    = true

      when 'correctiveaction'
        self.correctiveaction     = value
        result                    = true

      when 'fixed_in'
        self.fixed_in             = value
        result                    = true

      when 'verification'
        self.verification         = value
        result                    = true

      when 'feedback'
        self.feedback             = value
        result                    = true

      when 'notes'
        self.notes                = value
        result                    = true

      when 'meeting_id'
        self.meeting_id           = value
        result                    = true

      when 'safetyrelated'
        self.safetyrelated        = if (value =~ /^true$/i) ||
                                       (value =~ /^y(es){0,1}$/i)
                                      true
                                    elsif (value =~ /^false$/i) ||
                                          (value =~ /^n[o]{0,1}$/i)
                                      false
                                    else
                                      nil
                                    end
        result                    = true

      when 'datemodified'
        if value.present?
          begin
            self.datemodified     = DateTime.parse(value)
            result                = true
          rescue
            result                = false
          end
        else
          result                  = true
        end

      when 'referenced_artifacts'
        self.referenced_artifacts = JSON.parse(value) if value.present?
        result                    = true

      when 'archive_revision'
        self.archive_revision     = value
        result                    = true

      when 'archive_version'
        self.archive_version     = value.to_f if value.present?
        result                    = true
    end

    return result
  end

private
  # Method:      find_or_create_report_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the prid).
  #
  #              project an optional Project (default: default from @project),
  #              The project this report belongs to.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      A Problem Report Object.
  # Description: Finds or Creates a Problem Report Object by the ID in the line.
  # Calls:       None
  # Notes:       If the report already exists it is returned otherwise a
  #              a new one is created. In this case, if the id doesn't exist it
  #              is one greater than the last report id.
  # History:     06-05-2019 - First Written, PC

  def self.find_or_create_problem_report_by_id(columns,
                                               project = @project,
                                               headers = DEFAULT_HEADERS)
    id_at                       = headers.find_index('prid')
    id                          = columns[id_at].to_i if id_at.present? &&
                                                         (columns[id_at] =~ /^\d+\.*\d*$/)

    if id.present?
      problem_report            = ProblemReport.find_by(prid: id,
                                                        project_id: project.id)
    else
      last_id                   = nil
      problem_reports           = ProblemReport.where(project_id:   project.id,
                                                      organization: User.current.organization).order("prid")

      problem_reports.each do |report|
        if last_id.present? && (last_id != (report.prid - 1)) # we found a hole.
          id                    = last_id + 1

          break;
        end

        last_id                 = report.prid
      end

      id = if id.present?
             id
           elsif last_id.present?
             last_id + 1
           else
             1
           end
    end

    unless problem_report.present?
      problem_report            = ProblemReport.new()
      problem_report.project_id = project.id
      problem_report.prid       = id
    end

    return problem_report
  end
end
