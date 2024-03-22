class TemplateChecklist < OrganizationRecord
  belongs_to    :template
  has_many      :template_checklist_item, dependent: :destroy

  validates     :template_id, presence: true

  attr_accessor :new_checklist_name
  attr_accessor :archive_revision
  attr_accessor :archive_version

  # Generate Item identifier + reqid
  def name
    checklist_name  = if self.description.present?
                        self.description
                      elsif self.title.present?
                        self.title
                      else
                        self.clid
                      end

    checklist_name += "(#{self.checklist_class} #{self.checklist_type})"

    checklist_name
  end

  def self.template_description_from_title(title)
    result             = title
    template_checklist = TemplateChecklist.find_by(title:        title,
                                                   organization: User.current.organization)
    result             = "#{template_checklist.description} (#{template_checklist.checklist_class} #{template_checklist.checklist_type})" if template_checklist.present?

    return result
  end
  
  def self.get_checklists(item_type         = nil,
                          review_type       = nil,
                          remove_duplicates = false)
    result           = []
    last_description = nil
    checklist_type   = if (review_type =~ /^transition.*/i)
                         'Transition Review'
                       else
                         'Peer Review'
                       end

    checklist_class  = Constants::ItemType[item_type.to_i] if item_type.present?
    checklists       = if checklist_class.present? && checklist_type.present?
                         TemplateChecklist.where(checklist_type:  checklist_type,
                                                 checklist_class: checklist_class,
                                                 organization:    User.current.organization).order(:description)
                       elsif checklist_class.present?
                         TemplateChecklist.where(checklist_class: checklist_class,
                                                 organization:    User.current.organization).order(:description)
                       elsif checklist_type.present?
                         TemplateChecklist.where(checklist_type:  checklist_type,
                                                 organization:    User.current.organization).order(:description)
                       else
                         TemplateChecklist.where(organization:    User.current.organization).order(:description)
                       end

    if remove_duplicates
      checklists.each do |checklist|
        description        = checklist.description.downcase

        description.strip!
        description.gsub!(/\.$/, '')
        description.gsub!('&', 'and')

        if description != last_description
          result.push(checklist)

          last_description = checklist.description.downcase

          last_description.strip!
          last_description.gsub!(/\.$/, '')
          last_description.gsub!('&', 'and')
        end
      end
    else
      result = checklists.to_a
    end

    result
  end

  # CSV file handling
  DEFAULT_HEADERS   = %w{ clitemid title description note template_checklist_id reference minimumdal supplements status }
  PATMOS_178_HEADER = [ '#', 'Checklist Item', 'DO-178C or Other Guidance Reference', 'DAL', '', '', '',  'Supplements']
  PATMOS_254_HEADER = [ '#', 'Checklist Item', 'DO-254 or Other Guidance Reference', 'DAL',  '', '', '' ]

  # Create csv
  def to_csv
    attributes = DEFAULT_HEADERS

    template_checklist_items = TemplateChecklistItem.where(template_checklist_id: self.id, organization: User.current.organization)
  
    CSV.generate(headers: true) do |csv|
      csv << attributes
      template_checklist_items.each do |template_checklist_item|
        csv << attributes.map{ |attr| template_checklist_item.send(attr) }
      end
    end
  end

  def to_xls(headers = DEFAULT_HEADERS)
    xls_workbook     = Spreadsheet::Workbook.new
    xls_worksheet    = xls_workbook.create_worksheet
    current_row      = 0

    xls_worksheet.insert_row(current_row, headers)

    current_row     += 1

    template_checklist_item.order(:clitemid).each do |template_checklist_item|
      columns        = []

      headers.each do |attribute|
        if attribute == 'clitemid'
          value      = template_checklist_item[attribute].to_s
        elsif attribute == 'template_id'
          if template_checklist_item.template_id.present?
            template = Template.find_by(id: self.template_id)
            value    = template.try(:title)
          end
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

  # Import CSV File Routines

  # The normal Usage would be: from_csv('filename.csv')

  # Method:      from_csv
  # Parameters:  input a String or IO,
  #              if a string it's either a filename or a line from a file.
  #              If it's an IO it's an opened input stream.
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
  # Notes:       If the checklist item already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist item id.
  # History:     09-06-2019 - First Written, PC

  def from_file(input, headers = DEFAULT_HEADERS, file_has_header = false)
    result              = false
    @template_checklist = self

    if input.kind_of?(String)
      if input =~ /^.+\.csv$/i # If it's a csv filename
        result = from_csv_filename(input, headers, file_has_header)
      elsif input =~ /^.+\.xlsx/i # If it's a xlsx filename
        result = from_xlsx_filename(input, headers, file_has_header)
      elsif input =~ /^.+\.xls/i # If it's a xls filename
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
    sheet_number            = 0
    columns                 = []
    result                  = nil
    session_id              = nil
    xlsx_workbook           = Roo::Excelx.new(input_filename)

    xlsx_workbook.sheets.each do |xlsx_worksheet|
      first_row             = xlsx_workbook.first_row(xlsx_worksheet)
      last_row              = xlsx_workbook.last_row(xlsx_worksheet)

      next if first_row.nil? || last_row.nil?

      sheet_number         += 1

      if file_has_header
        found               = false

        while (first_row < last_row) && !found
          columns           = xlsx_workbook.row(first_row, xlsx_worksheet)

          columns.each do |cell|
            next unless cell.present?

            found           = (cell.to_s == headers[0])

            if found
              headers       = []

              columns.each do |column|
                column      = '' unless column.present?

                headers.push(column.to_s)
              end unless columns.nil?

              break
            end
          end unless columns.nil?

          first_row        += 1

          break if found
        end
      else
        current_row         = first_row

        while (current_row < last_row) && !found
          columns           = xlsx_workbook.row(current_row, xlsx_worksheet)

          columns.each do |cell|
            next unless cell.present?

            found           = (cell.to_s == headers[0])

            if found
              first_row     = current_row + 1

              break
            end
          end unless columns.nil?

          current_row      += 1

          break if found
        end
      end

      if (sheet_number > 1) &&
         !xlsx_workbook.row(first_row, xlsx_worksheet)[4].present?
        template_checklist  = TemplateChecklist.new(clid:            TemplateChecklist.maximum("clid") + 1,
                                                    title:           xlsx_worksheet,
                                                    description:     xlsx_worksheet,
                                                    notes:           '',
                                                    checklist_class: self.checklist_class,
                                                    checklist_type:  self.checklist_type,
                                                    template_id:     self.template_id,
                                                    filename:        input_filename)

        DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                     'create',
                                                     nil,
                                                     'template_checklists', 
                                                     session_id)

        @template_checklist = template_checklist
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

        template_checklist_item = find_or_create_template_checklist_item_by_id(columns,
                                                                               headers)

        return result unless template_checklist_item.present?

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name    = if index < headers.length
                               headers[index]
                             else
                               nil
                             end

            if column_name.present?
              result       = assign_column(template_checklist_item,
                                           column_name,
                                           column)
            end

            break unless result
          end

          result = DataChange.save_or_destroy_with_undo_session(template_checklist_item,
                                                                template_checklist_item.id.present? ? 'update' : 'create',
                                                                template_checklist_item.id,
                                                                'template_checklist_items', 
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

  # Method:      from_patmos_template
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

  def from_patmos_template(input_filename,
                           headers_DO_178 = PATMOS_178_HEADER,
                           headers_DO_254 = PATMOS_254_HEADER)
    sheet_number              = 0
    result                    = nil
    session_id                = nil
    xlsx_workbook             = Roo::Excelx.new(input_filename)
    @template_checklist       = self

    xlsx_workbook.sheets.each do |xlsx_worksheet|
      first_row               = xlsx_workbook.first_row(xlsx_worksheet)
      last_row                = xlsx_workbook.last_row(xlsx_worksheet)
      columns                 = []
      first_column            = nil
      found                   = false
      supplements_present     = false

      next if first_row.nil?                          ||
              last_row.nil?                           ||
              xlsx_worksheet =~ /^\s*disclaimer\s*$/i ||
              xlsx_worksheet =~ /^\s*revisions\s*$/i  ||
              xlsx_worksheet =~ /^\s*revisions\s*$/i  ||
              xlsx_worksheet =~ /^\s*read\s*me\s*$/i

      sheet_number           += 1

      while (first_row < last_row) && !found
        columns               = xlsx_workbook.row(first_row, xlsx_worksheet)

        columns.each_with_index do |cell, index|
          next unless cell.present?

          found               = (cell.to_s == headers_DO_178[0])
          supplements_present = true if (cell.to_s == 'Supplements')

          if found
            first_column      = index

            break
          end
        end unless columns.nil?

        if found
          columns.each_with_index do |cell, index|
            next unless cell.present?

            supplements_present = true if (cell.to_s == 'Supplements')

            if supplements_present
              break
            end
          end unless columns.nil?
        end

        first_row            += 1

        break if found
      end

      next unless found

      if sheet_number > 1
        template_checklist    = TemplateChecklist.new(clid:            TemplateChecklist.maximum("clid").present? ? (TemplateChecklist.maximum("clid") + 1) : 1,
                                                      title:           xlsx_worksheet,
                                                      description:     xlsx_worksheet,
                                                      notes:           '',
                                                      checklist_class: self.checklist_class,
                                                      checklist_type:  self.checklist_type,
                                                      template_id:     @template_checklist.template_id,
                                                      filename:        input_filename)

        DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                     'create',
                                                     nil,
                                                     'template_checklists', 
                                                     session_id)

        @template_checklist   = template_checklist
      end

      for row in first_row...(last_row + 1) do
        row_columns           = xlsx_workbook.row(row, xlsx_worksheet)

        next if (row_columns.length < (first_column + 2)) ||
                 row_columns[first_column].nil?

        minimumdal            = ''
        supplements           = ''

        if row_columns[first_column + 3] == 'X'
          minimumdal         += 'A' 
        end

        if row_columns[first_column + 4] == 'X'
          minimumdal         += minimumdal.present? ? ',B' : 'B'
        end

        if row_columns[first_column + 5] == 'X'
          minimumdal         += minimumdal.present? ? ',C' : 'C'
        end

        if row_columns[first_column + 6] == 'X'
          minimumdal         += minimumdal.present? ? ',D' : 'D'
        end

        if supplements_present
          if row_columns[first_column + 7] == 'X'
            supplements      += 'Model Based' 
          end

          if row_columns[first_column + 8] == 'X'
            supplements      += supplements.present? ? ',Object Oriented' : 'Object Oriented'
          end

          if row_columns[first_column + 9] == 'X'
            supplements      += supplements.present?  ? ',Formal Method' : 'Formal Method'
          end
        end

        template_checklist_item = find_or_create_template_checklist_item_by_id([ row_columns[first_column] ],
                                                                               [ 'clitemid' ])

        return result unless template_checklist_item.present?

        template_checklist_item.template_checklist_id = @template_checklist.id

        result                  = assign_column(template_checklist_item,
                                                'clitemid',
                                                row_columns[first_column].to_s)

        return result unless result

        result                  = assign_column(template_checklist_item,
                                                'title',
                                                row_columns[first_column + 1])

        return result unless result

        result                  = assign_column(template_checklist_item,
                                                'description',
                                                row_columns[first_column + 1])

        return result unless result

        result                  = assign_column(template_checklist_item,
                                                'reference',
                                                row_columns[first_column + 2])

        return result unless result

        result                  = assign_column(template_checklist_item,
                                                'minimumdal',
                                                minimumdal)

        return result unless result

        result                  = assign_column(template_checklist_item,
                                                'supplements',
                                                supplements)

        return result unless result

        result = DataChange.save_or_destroy_with_undo_session(template_checklist_item,
                                                              template_checklist_item.id.present? ? 'update' : 'create',
                                                              template_checklist_item.id,
                                                              'template_checklist_items', 
                                                              session_id)
        if result.present?
          session_id = result.session_id
        else
          return false
        end
      end
    end

    result = true

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
    sheet_number                       = 0
    session_id                         = nil
    result                             = false
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

      sheet_number           += 1

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

      if (sheet_number > 1) &&
         !xls_worksheet.cell(first_row, first_column + 4).present?
        template_checklist             = TemplateChecklist.new(clid:            TemplateChecklist.maximum("clid") + 1,
                                                               title:           xls_worksheet.name,
                                                               description:     xls_worksheet.name,
                                                               notes:           '',
                                                               checklist_class: self.checklist_class,
                                                               checklist_type:  self.checklist_type,
                                                               template_id:     self.template_id,
                                                               filename:        input_filename)

        DataChange.save_or_destroy_with_undo_session(template_checklist,
                                                     'create',
                                                     nil,
                                                     'template_checklists', 
                                                     session_id)

        @template_checklist            = template_checklist
      end

      for row in first_row...last_row do
        columns                        = []
        column_number                  = 0

        for current_col in first_column..last_column
          columns[column_number]       = xls_worksheet.cell(row, current_col)
          columns[column_number]       = columns[column_number].to_s if columns[column_number].present?
          column_number               += 1        
        end

        template_checklist_item = find_or_create_template_checklist_item_by_id(columns,
                                                                               headers)

        return result unless template_checklist_item.present?

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name                = if index < headers.length
                                           headers[index]
                                         else
                                           nil
                                         end

            if column_name.present?
              result              = assign_column(template_checklist_item,
                                                  column_name,
                                                  column)
            end

            break unless result
          end

          result = DataChange.save_or_destroy_with_undo_session(template_checklist_item,
                                                                template_checklist_item.id.present? ? 'update' : 'create',
                                                                template_checklist_item.id,
                                                                'template_checklist_items', 
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
  # Notes:       If the checklist item already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist item id.
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
          (file_has_header || (row[0] =~ /\s*clitemid\s*/))
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
  # Notes:       If the checklist item already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist item id.
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
  # Calls:       find_or_create_checklist item_by_id, assign_column
  # Notes:       If the checklist item already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist item id.
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

    template_checklist_item = find_or_create_template_checklist_item_by_id(columns,
                                                                           headers)

    if template_checklist_item.present?
      columns.each_with_index do |value, index|
        column_name         = if index < headers.length
                                headers[index]
                              else
                                nil
                              end

        result              = assign_column(template_checklist_item,
                                            column_name,
                                            value) if column_name.present?

        break unless result
      end

      result                = DataChange.save_or_destroy_with_undo_session(template_checklist_item,
                                                                           template_checklist_item.id.present? ? 'update' : 'create',
                                                                           template_checklist_item.id, 'template_checklist_items', 
                                                                           session_id)
    end

    return result
  end

private

  # Method:      assign_column
  # Parameters:  template_checklist_item a TemplateChecklistItem,
  #              the item to assign the column to.
  #
  #              column_name a String,
  #              The name of the column to be assigned.
  #
  #              value an object,
  #              The value to set the column to.
  #              
  # Return:      A Boolean, true if the value was assigned false otherwise.
  # Description: Assigns a valiue to a specic value in the TemplateChecklistItem
  # Calls:       None
  # Notes:       
  # History:     09-06-2019 - First Written, PC

  def assign_column(template_checklist_item, column_name, value)
    result                                            = false

    case column_name
      when 'clitemid'
        if value =~ /^\d+\.*\d*$/
          template_checklist_item.clitemid            = value.to_i
          result                                      = true
        elsif value.nil?
          result                                      = true
        end
      when 'title'
        template_checklist_item.title                 = value
        result                                        = true
      when 'description'
        template_checklist_item.description           = value
        result                                        = true
      when 'note'
        template_checklist_item.note                  = value
        result                                        = true
      when 'template_checklist_id'
        template_checklist_id                         = @template_checklist.id

        if value.present?
          template_checklist                          = if value =~ /^\d+\.*\d*$/
                                                          TemplateChecklist.find_by(id: value.to_i)
                                                        else
                                                          TemplateChecklist.find_by(title: value)
                                                        end

          template_checklist_id                       = template_checklist.id if template_checklist.present?
        end

        template_checklist_item.template_checklist_id = template_checklist_id
        result                                        = true
      when 'reference'
        template_checklist_item.reference             = value
        result                                        = true
      when 'minimumdal'
        if value.present?
          value.gsub!('[', '');
          value.gsub!(']', '');
          value.gsub!('"', '');
          value.gsub!("'", '');
          value.gsub!(' ', '');
  
          template_checklist_item.minimumdal          = value.split(',')
        end

        result                                        = true
      when 'supplements'
        if value.present?
          value.gsub!('[', '');
          value.gsub!(']', '');
          value.gsub!('"', '');
          value.gsub!("'", '');

          template_checklist_item.supplements         = value.split(',')
        end

        result                                        = true
      when 'status'
        template_checklist_item.status                = value
        result                                        = true
      when 'archive_revision'
        result                                        = true
      when 'archive_version'
        result                                        = true
    end

    return result
  end

  # Method:      find_or_create_checklist_item_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the clitemid).
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      A Template Checklist Item Object.
  # Description: Finds or Creates a Template Checklist Item Object by the ID in the line.
  # Calls:       None
  # Notes:       If the requirement already exists it is returned otherwise a
  #              a new one is created. In this case, if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-06-2019 - First Written, PC

  def find_or_create_template_checklist_item_by_id(columns,
                                                   headers = DEFAULT_HEADERS)
    id_at                                           = headers.find_index('clitemid')
    template_checklist_item_id                      = columns[id_at].to_i if id_at.present? &&
                                                                             columns[id_at] =~ /^\d+\.*\d*$/

    if template_checklist_item_id.present?
      template_checklist_item                       = TemplateChecklistItem.find_by(clitemid:              template_checklist_item_id,
                                                                                    template_checklist_id: self.id)
    else
      last_id                                       = nil
      template_checklist_items                      = TemplateChecklistItem.where(template_checklist_id: self.id, organization: User.current.organization).order("clitemid")

      template_checklist_items.each do |checklist_item|
        if last_id.present? &&
           (last_id != (checklist_item.clitemid - 1)) # we found a hole.
          template_checklist_item_id                = last_id + 1

          break;
        end

        last_id                                     = checklist_item.clitemid
      end

      template_checklist_item_id                    = if template_checklist_item_id.present?
                                                        template_checklist_item_id
                                                      elsif last_id.present?
                                                        last_id + 1
                                                      else
                                                        1
                                                      end
    end

    unless template_checklist_item.present?
      template_checklist_item                       = TemplateChecklistItem.new()
      template_checklist_item.template_checklist_id = self.id
      template_checklist_item.clitemid              = template_checklist_item_id
    end

    return template_checklist_item
  end
end
