class Template < OrganizationRecord
  has_many      :template_checklist, dependent: :destroy
  has_many      :template_document, dependent: :destroy

  attr_accessor :archive_revision
  attr_accessor :archive_version

  GLOBAL_ORGANIZATION = 'global'

  def self.remove_template_checklist_items(source, organization, session_id = nil)
    template_checklist_items = TemplateChecklistItem.where(source:       source,
                                                           organization: organization)

    return true unless template_checklist_items.present?

    template_checklist_items.each do |template_checklist_item|
      data_change = DataChange.save_or_destroy_with_undo_session(template_checklist_item,
                                                                 'delete',
                                                                 template_checklist_item.id,
                                                                 'template_checklist_items',
                                                                 session_id)

      if data_change.present?
        session_id  = data_change.session_id
      else
        return nil
      end
    end

    return session_id
  end

  def self.remove_template_checklists(source, organization, session_id = nil)
    template_checklists = TemplateChecklist.where(source:       source,
                                                  organization: organization)

    return true unless template_checklists.present?

    template_checklists.each do |template_checklist|
      data_change = DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                                 'delete',
                                                                 template_checklist.id,
                                                                 'template_checklists',
                                                                 session_id)

      if data_change.present?
        session_id  = data_change.session_id
      else
        return nil
      end
    end

    return session_id
  end

  def self.remove_template_documents(source, organization, session_id = nil)
    template_documents = TemplateDocument.where(source:         source,
                                                  organization: organization)


    return true unless template_documents.present?

    template_documents.each do |template_document|
      data_change = DataChange.save_or_destroy_with_undo_session(template_document,
                                                                 'delete',
                                                                 template_document.id,
                                                                 'template_documents',
                                                                 session_id)

      if data_change.present?
        session_id  = data_change.session_id
      else
        return nil
      end
    end

    return session_id
  end

  def self.remove_templates(source, organization)
    session_id = self.remove_template_checklist_items(source, organization)

    return session_id if session_id.nil?

    session_id = nil if session_id == true
    
    session_id = self.remove_template_checklists(source, organization, session_id)

    return session_id if session_id.nil?

    session_id = nil if session_id == true
    
    session_id = self.remove_template_documents(source, organization, session_id)

    return session_id if session_id.nil?

    session_id = nil if session_id == true
    
    templates = Template.where(source: source, organization: organization)

    templates.each do |template|
      data_change = DataChange.save_or_destroy_with_undo_session(template,
                                                                 'delete',
                                                                 template.id,
                                                                 'templates',
                                                                 session_id)

      if data_change.present?
        session_id  = data_change.session_id
      else
        return nil
      end
    end

    return session_id
  end

  def self.duplicate_global_templates
    session_id     = self.remove_templates(Constants::AWC, User.current.organization)
    templates      = Template.where(organization: GLOBAL_ORGANIZATION)
    session_id     = nil

    templates.each do |original_template|
      new_template = original_template.dup
      data_change  = DataChange.save_or_destroy_with_undo_session(new_template,
                                                                  'create',
                                                                  nil,
                                                                  'templates',
                                                                  session_id)
      session_id   = data_change.session_id

      original_template.template_document.each do |original_template_document|
        self.duplicate_global_templates_document(original_template_document,
                                                 new_template,
                                                 session_id)
      end if original_template.template_document.present?

      original_template.template_checklist.each do |original_template_checklist|
        self.duplicate_global_templates_checklist(original_template_checklist,
                                                  new_template,
                                                  session_id)
      end if original_template.template_checklist.present?
    end if templates.present?
  end

  def self.duplicate_global_templates_document(original_template_document,
                                               new_template,
                                               session_id)
    file                    = original_template_document.file if original_template_document.file.attached?
    new_template_document = TemplateDocument.new()

    original_template_document.attributes.each do |attribute, index|
      if (attribute != 'id') && (attribute != 'template_id')
        new_template_document[attribute] = original_template_document[attribute]
      end
    end

    new_template_document.template_id = new_template.id

    if file.present?
      begin
        new_template_document.file.attach(io:           StringIO.new(file.download),
                                          filename:     file.filename,
                                          content_type: file.content_type)
      rescue Errno::EACCES
        new_template_document.file.attach(io:           StringIO.new(file.download),
                                          filename:     file.filename,
                                          content_type: file.content_type)
      end
    end

    DataChange.save_or_destroy_with_undo_session(new_template_document,
                                                 'create',
                                                 nil,
                                                 'template_documents',
                                                 session_id)
  end

  def self.duplicate_global_templates_checklist(original_template_checklist,
                                                new_template,
                                                session_id)
    new_template_checklist             = original_template_checklist.dup
    new_template_checklist.template_id = new_template.id

    DataChange.save_or_destroy_with_undo_session(new_template_checklist,
                                                 'create',
                                                 nil,
                                                 'template_checklists',
                                                 session_id)

    original_template_checklist.template_checklist_item.each do |original_template_checklist_item|
      self.duplicate_global_templates_checklist_item(original_template_checklist_item,
                                                     new_template_checklist,
                                                     session_id)
    end if original_template_checklist.template_checklist_item.present?
  end

  def self.duplicate_global_templates_checklist_item(original_template_checklist_item,
                                                     new_template_checklist,
                                                     session_id)
    new_template_checklist_item                       = original_template_checklist_item.dup
    new_template_checklist_item.template_checklist_id = new_template_checklist.id

    DataChange.save_or_destroy_with_undo_session(new_template_checklist_item,
                                                 'create',
                                                 nil,
                                                 'template_checklist_items',
                                                 session_id)
  end

  # CSV file handling
  DEFAULT_HEADERS = %w{ clid title description notes checklist_class checklist_type template_id }

  # Create csv
  def to_csv
    attributes          = DEFAULT_HEADERS

    template_checklists = TemplateChecklist.where(template_id: self.id, organization: User.current.organization)

    CSV.generate(headers: true) do |csv|
      csv << attributes
      template_checklists.each do |template_checklist|
        csv << attributes.map{ |attr| template_checklist.send(attr) }
      end
    end
  end

  def to_xls(headers = DEFAULT_HEADERS)
    xls_workbook     = Spreadsheet::Workbook.new
    xls_worksheet    = xls_workbook.create_worksheet
    current_row      = 0

    xls_worksheet.insert_row(current_row, headers)

    current_row     += 1

    template_checklist.order(:clid).each do |template_checklist|
      columns        = []

      headers.each do |attribute|
        if attribute == 'clid'
          value      = template_checklist_item[attribute].to_s
        else
          value      = template_checklist_item[attribute]
          value      = Sanitize.fragment(value).gsub('&nbsp;',
                                                   ' ').strip if value.kind_of?(String)
        end

        columns.push(value)
      end

      xls_worksheet.insert_row(current_row, columns)

      current_row   += 1
    end

    file             = Tempfile.new('template-checklist')

    xls_workbook.write(file.path)
    file.rewind

    result           = file.read

    file.close
    file.unlink

    return result
  end

  # Import File Routines

  # The normal Usage would be: from_file('filename.csv')

  # Method:      from_file
  # Parameters:  input a String or IO,
  #              if a string it's either a filename or a line from a file.
  #              If it's an IO it's an opened input stream.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: false),
  #              If true the file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV, xlsx or xls file into the Requiremens.
  # Calls:       from_csv_file, from_xlsx_filename, from_xls_filename,
  #              from_csv_io, or from_csv_string
  # Notes:       If the checklist already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist id.
  # History:     09-06-2019 - First Written, PC

  def from_file(input, headers = DEFAULT_HEADERS, file_has_header = false)
    result = false

    if input.kind_of?(String)
      if input =~ /^.+\.csv$/i # If it's a csv filename
        result = from_csv_filename(input, headers, file_has_header)
      elsif input =~ /^.+\.xlsx$/i # If it's a xlsx filename
        result = from_xlsx_filename(input, headers, file_has_header)
      elsif input =~ /^.+\.xls$/i # If it's a xls filename
        result = from_xls_filename(input, headers, file_has_header)
      else                     # If is a line from a csv file
        result = from_csv_string(input, headers)
      end
    elsif input.kind_of?(IO)    # If it's an input stream
      result = from_csv_io(input, headers)
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
  #              file_has_header an optional boolean (default: false),
  #              If true the XLSX file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLSX file into the Template Checklist Items
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def from_xlsx_filename(input_filename,
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

        template_checklist = find_or_create_template_checklist_by_id(columns,
                                                                     headers)

        return result unless template_checklist.present?

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name    = if index < headers.length
                               headers[index]
                             else
                               nil
                             end

            if column_name.present?
              result       = assign_column(template_checklist,
                                           column_name,
                                           column)
            end

            break unless result
          end

          result = DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                                template_checklist.id.present? ? 'update' : 'create',
                                                                template_checklist.id,
                                                                'template_checklists', 
                                                                session_id)
          if result.present?
            session_id = result.session_id
          else
            return false
          end
        end
      end
    end

    result                 = true

    return result
  end

  # Method:      from_xls_filename
  # Parameters:  input_filename a String, the filename to import.
  #
  #              project an optional Project (default: default from @project),
  #              The project this requirement belongs to.
  #
  #              headers an optional array of strings (default: DEFAULT_HEADERS),
  #              The headers for the file.
  #
  #              file_has_header an optional boolean (default: false),
  #              If true the XLS file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from an XLS file into the Template Checklist Items.
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def from_xls_filename(input_filename,
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

        template_checklist = find_or_create_template_checklist_by_id(columns,
                                                                     headers)

        return result unless template_checklist.present?

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name                = if index < headers.length
                                           headers[index]
                                         else
                                           nil
                                         end

            if column_name.present?
              result              = assign_column(template_checklist,
                                                  column_name,
                                                  column)
            end

            break unless result
          end

          result = DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                                template_checklist.id.present? ? 'update' : 'create',
                                                                template_checklist.id,
                                                                'template_checklists', 
                                                                session_id)
          if result.present?
            session_id = result.session_id
          else
            return false
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
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  #              file_has_header an optional boolean (default: false),
  #              If true the CSV file has a header.
  #
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the checklist it already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist id.
  # History:     09-06-2019 - First Written, PC
  def from_csv_filename(filename,
                        headers            = DEFAULT_HEADERS,
                        file_has_header    = false)
    result               = false
    first_line           = true
    session_id           = nil

    if File.readable?(filename)
      CSV.foreach(filename) do |row|
        if first_line &&
          (file_has_header || (row[0] =~ /\s*clid\s*/))
          headers        = row.map do |column|
                              (column =~ /\s*([A-Za-z_ ]+)\s*/) ? $1 : column
                           end
        else
          change_session = from_csv_string(row, headers, session_id)

          next if change_session == :skip

          return result unless change_session.present?

          session_id = change_session.session_id
        end

        first_line       = false
      end

      result             = true
    else
      message            = "The file '#{filename}' is not readable or does not exist."

      errors.add(:name, :blank, message: message)
    end

    return result
  end

  # Method:      from_csv_io
  # Parameters:  file an IO,
  #              The opened input stream.
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the Requiremens.
  # Calls:       from_csv_string
  # Notes:       If the checklist already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist id.
  # History:     09-06-2019 - First Written, PC

  def from_csv_io(file, headers = DEFAULT_HEADERS)
    result     = false
    session_id = nil

    while (line = io.readline)
      result     = from_csv_string(line, headers, session_id)

      next if result == :skip

      session_id = result.session_id

      break unless result
    end

    return result
  end

  # Method:      from_csv_string
  # Parameters:  line a String,
  #              The line from the CSV File
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      True if it was imported successfully false otherwise.
  # Description: This imports data from a CSV file into the template check list.
  # Calls:       find_or_create_template_checklist_by_id, assign_column
  # Notes:       If the checklist already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist id.
  # History:     09-06-2019 - First Written, PC

  def from_csv_string(line, headers = DEFAULT_HEADERS, session_id = nil)
    result                  = false
    columns                 = []

    begin
      if line.kind_of?(String)
        columns             = CSV.parse_line(line)
      elsif line.kind_of?(Array)
        columns             = line
      end
    rescue e
      message               = "Cannot parse CSV.\nError: #{e.message}.\nLine:  '#{line}'"

      errors.add(:name, :blank, message: message)

      return result
    end

    return :skip if columns.empty? # skip empty lines

    template_checklist = find_or_create_template_checklist_by_id(columns,
                                                                 headers)

    if template_checklist.present?
      columns.each_with_index do |value, index|
        column_name         = if index < headers.length
                                headers[index]
                              else
                                nil
                              end

        result              = assign_column(template_checklist,
                                            column_name,
                                            value) if column_name.present?

        break unless result
      end

      result                = DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                                           template_checklist.id.present? ? 'update' : 'create',
                                                                           template_checklist.id, 'template_checklists', 
                                                                           session_id)
    end

    return result
  end

private

  # Method:      assign_column
  # Parameters:  template_checklist a TemplateChecklist,
  #              the item to assign the column to.
  #
  #              column_name a String,
  #              The name of the column to be assigned.
  #
  #              value an object,
  #              The value to set the column to.
  #              
  # Return:      A Boolean, true if the value was assigned false otherwise.
  # Description: Assigns a valiue to a specic value in the TemplateChecklist
  # Calls:       None
  # Notes:       
  # History:     09-06-2019 - First Written, PC

  def assign_column(template_checklist, column_name, value)
    result                                 = false

    case column_name
      when 'clid'
        if value =~ /^\d+\.*\d*$/
          template_checklist.clid          = value.to_i
          result                           = true
        elsif value.nil?
          result                           = true
        end
      when 'title'
        template_checklist.title           = value
        result                             = true
      when 'description'
        template_checklist.description     = value
        result                             = true
      when 'notes'
        template_checklist.notes           = value
        result                             = true
      when 'checklist_class'
        template_checklist.checklist_class = value
        result                             = true
      when 'checklist_type'
        template_checklist.checklist_type  = value
        result                             = true
      when 'template_id'
        template_id                        = self.id

        if value.present?
          template                         = if value =~ /^\d+\.*\d*$/
                                               Template.find_by(id: value.to_i)
                                             else
                                               Template.find_by(title: value)
                                             end

          template_id                      = template.id if template.present?
        end

        template_checklist.template_id     = template_id
        result                             = true
      when 'archive_revision'
        self.archive_revision              = value
        result                             = true
      when 'archive_version'
        self.archive_version              = value.to_f if value.present?
        result                             = true
    end

    return result
  end

  # Method:      find_or_create_template_checklist_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the clid).
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      A Template Checklist Object.
  # Description: Finds or Creates a Template Checklist  Object by the ID in the line.
  # Calls:       None
  # Notes:       If the requirement already exists it is returned otherwise a
  #              a new one is created. In this case, if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-06-2019 - First Written, PC

  def find_or_create_template_checklist_by_id(columns,
                                              headers = DEFAULT_HEADERS)
    id_at                            = headers.find_index('clid')
    template_checklist_id            = columns[id_at].to_i if id_at.present? &&
                                       columns[id_at] =~ /^\d+\.*\d*$/

    if template_checklist_id.present?
      template_checklist             = TemplateChecklist.find_by(clid:        template_checklist_id,
                                                                 template_id: self.id)
    else
      last_id                        = nil
      template_checklists            = TemplateChecklist.where(template_id: self.id, organization: User.current.organization).order("clid")

      template_checklists.each do |checklist|
        if last_id.present? &&
           (last_id != (checklist.clid - 1)) # we found a hole.
          template_checklist_id      = last_id + 1

          break;
        end

        last_id                      = checklist.clid
      end

      template_checklist_id          = if template_checklist_id.present?
                                         template_checklist_id
                                       elsif last_id.present?
                                         last_id + 1
                                       else
                                         1
                                       end
    end

    unless template_checklist.present?
      template_checklist             = TemplateChecklist.new()
      template_checklist.template_id = self.id
      template_checklist.clid        = template_checklist_id
    end

    return template_checklist
  end
end
