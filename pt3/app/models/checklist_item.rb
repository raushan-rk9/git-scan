class ChecklistItem < OrganizationRecord
  belongs_to :review
  belongs_to :document, optional: true
  has_one    :user

  # Define supplements as an array type.
  serialize :supplements, Array

  attr_accessor :archive_revision
  attr_accessor :archive_version

  def self.consolidate_checklist_items(review_id, checklists_assigned)
    users                                         = User.all
    user_list                                     = {}
    
    users.each do |user|
      user_list[user.id] = user.fullname
    end

    items                                         = ChecklistItem.where(review_id: review_id).order(:clitemid)
    checklist_items                               = items.to_a.sort do |x, y|
                                                      if (x.clitemid == y.clitemid) &&
                                                          x.user_id.present?        &&
                                                          y.user_id.present?
                                                        user_list[x.user_id] <=> user_list[y.user_id]
                                                      else
                                                        x.clitemid <=> y.clitemid
                                                      end
                                                    end
    consolidated_items                            = []
    item                                          = {}
    previous_clitem_id                            = nil
    last_status                                   = nil
    last_note                                     = nil

    if checklists_assigned
      checklist_items.each() do |checklist_item|
        next unless checklist_item.user_id.present?

        if previous_clitem_id.nil?
          item                                    = {}
          item[:statuses]                         = {}
          item[:notes]                            = {}
#          item[:statuses_match]                   = true
          item[:notes_match]                      = true
          item[:clitemid]                         = checklist_item.clitemid
          item[:description]                      = checklist_item.description
          item[:statuses][checklist_item.user_id] = checklist_item.status
          item[:notes][checklist_item.user_id]    = checklist_item.note
          last_status                             = checklist_item.status
          last_note                               = checklist_item.note
          previous_clitem_id                      = checklist_item.clitemid
        elsif checklist_item.clitemid == previous_clitem_id
          item[:statuses][checklist_item.user_id] = checklist_item.status
          item[:notes][checklist_item.user_id]    = checklist_item.note

          if item[:statuses_match] && (checklist_item.status != last_status)
            item[:statuses_match]                 = false
            last_status                           = checklist_item.status
          end

          if item[:notes_match] && (checklist_item.note != last_note)
            item[:notes_match]                    = false
            last_status                           = checklist_item.note
          end
        else
          consolidated_items.push(item) if item.present?

          item                                    = {}
          item[:statuses]                         = {}
          item[:notes]                            = {}
#          item[:statuses_match]                   = true
          item[:notes_match]                      = true
          item[:clitemid]                         = checklist_item.clitemid
          item[:description]                      = checklist_item.description
          item[:statuses][checklist_item.user_id] = checklist_item.status
          item[:notes][checklist_item.user_id]    = checklist_item.note
          last_status                             = checklist_item.status
          last_note                               = checklist_item.note
          previous_clitem_id                      = checklist_item.clitemid
        end
      end

      consolidated_items.push(item) if item.present?
    else
      checklist_items.each() do |checklist_item|
        item                                      = {}
        item[:statuses]                           = {}
        item[:notes]                              = {}
#        item[:statuses_match]                     = true
        item[:notes_match]                        = true
        item[:clitemid]                           = checklist_item.clitemid
        item[:description]                        = checklist_item.description
        item[:statuses][checklist_item.user_id]   = checklist_item.status
        item[:notes][checklist_item.user_id]      = checklist_item.note

        consolidated_items.push(item)
      end
    end

    return consolidated_items
  end

  CONSOLIDATED_HEADERS      = %w{ID Description Status Notes}

  def self.to_consolidated_csv(review_id, checklists_assigned)
    consolidated_items = self.consolidate_checklist_items(review_id,
                                                          checklists_assigned)
    attributes         = CONSOLIDATED_HEADERS

    CSV.generate(headers: true) do |csv|
      csv << attributes

      consolidated_items.each do |checklist_item|
        columns        = []

        columns.push(checklist_item[:clitemid])
        columns.push(checklist_item[:description])

        if checklist_item[:statuses_match]
          columns.push(checklist_item[:statuses].first[1])
        else
          statuses     = ""

          checklist_item[:statuses].each do |key, value|
            statuses  += if statuses.present?
                           ",\n#{User.find(key).fullname}: #{value}"
                         else
                           "#{User.find(key).fullname}: #{value}"
                         end
          end

          columns.push(statuses)
        end

        if checklist_item[:notes_match]
          columns.push(checklist_item[:notes].first[1])
        else
          notes        = ""

          checklist_item[:notes].each do |key, value|
            notes     += if notes.present?
                          ",\n#{User.find(key).fullname}: '#{ActionView::Base.full_sanitizer.sanitize(value)}'"
                        else
                          "#{User.find(key).fullname}: '#{ActionView::Base.full_sanitizer.sanitize(value)}'"
                        end
          end

          columns.push(notes)
        end

        csv << columns
      end
    end
  end

  def self.to_consolidated_xls(review_id, checklists_assigned)
    consolidated_items = self.consolidate_checklist_items(review_id,
                                                          checklists_assigned)
    attributes         = CONSOLIDATED_HEADERS
    xls_workbook       = Spreadsheet::Workbook.new
    xls_worksheet      = xls_workbook.create_worksheet
    current_row        = 0

    xls_worksheet.insert_row(current_row, attributes)

    current_row       += 1

    consolidated_items.each do |checklist_item|
      columns          = []

      columns.push(checklist_item[:clitemid])
      columns.push(checklist_item[:description])

      if checklist_item[:statuses_match]
        columns.push(checklist_item[:statuses].first[1])
      else
        statuses       = ""

        checklist_item[:statuses].each do |key, value|
          statuses    += if statuses.present?
                           ",\n#{User.find(key).fullname}: #{value}"
                         else
                           "#{User.find(key).fullname}: #{value}"
                         end
        end

        columns.push(statuses)
      end

      if checklist_item[:notes_match]
        columns.push(checklist_item[:notes].first[1])
      else
        notes        = ""

        checklist_item[:notes].each do |key, value|
          notes     += if notes.present?
                        ",\n#{User.find(key).fullname}: '#{ActionView::Base.full_sanitizer.sanitize(value)}'"
                      else
                        "#{User.find(key).fullname}: '#{ActionView::Base.full_sanitizer.sanitize(value)}'"
                      end
        end

        columns.push(notes)
      end

      xls_worksheet.insert_row(current_row, columns)

      current_row += 1
    end

    file = Tempfile.new('consolidated-checklist')

    xls_workbook.write(file.path)
    file.rewind

    result = file.read

    file.close
    file.unlink

    return result
  end

  # CSV file handling
  DEFAULT_HEADERS   = %w{ clitemid review_id document_id description note reference minimumdal supplements status evaluator evaluation_date }
  PATMOS_178_HEADER = [ '#', 'Checklist Item', 'DO-178C or Other Guidance Reference', 'DAL', '', '', '',  'Supplements']
  PATMOS_254_HEADER = [ '#', 'Checklist Item', 'DO-254 or Other Guidance Reference', 'DAL',  '', '', '' ]
  GENERIC_HEADER    = [ '#', 'Checklist Item', 'Pertinent Reference', 'DAL',  '', '', '' ]

  # Create csv
  def self.to_csv(review_id,
                  user_email     = nil,
                  header         = DEFAULT_HEADERS,
                  display_header = DEFAULT_HEADERS,
                  pre_header     = nil)
    checklist_items = if user_email.present?
                        ChecklistItem.where(review_id: review_id,
                                            evaluator: user_email).order(:clitemid)
                      else
                        ChecklistItem.where(review_id: review_id).order(:clitemid)
                      end

    CSV.generate(headers: true) do |csv|
      pre_header.each do |row|
        csv << row
      end if pre_header.present?

      csv << display_header

      checklist_items.each do |checklist_item|
        csv << header.map{ |attr| checklist_item.send(attr) }
      end
    end
  end

  def self.to_xls(review_id,
                  user_email     = nil,
                  header         = DEFAULT_HEADERS,
                  display_header = DEFAULT_HEADERS,
                  pre_header     = nil)
    checklist_items    = if user_email.present?
                           ChecklistItem.where(review_id: review_id,
                                               evaluator: user_email).order(:clitemid)
                         else
                           ChecklistItem.where(review_id: review_id).order(:clitemid)
                         end
    xls_workbook       = Spreadsheet::Workbook.new
    xls_worksheet      = xls_workbook.create_worksheet
    current_row        = 0

    pre_header.each do |row|
      xls_worksheet.insert_row(current_row, row)

      current_row     += 1
    end if pre_header.present?

    xls_worksheet.insert_row(current_row, display_header)

    current_row       += 1

    checklist_items.each do |checklist_item|
      columns          = []

      header.each do |attribute|
        if attribute == "supplements"
          value = checklist_item[attribute].join("\n")
        else
          value = Sanitize.fragment(checklist_item[attribute]).gsub('&nbsp;', ' ').strip
        end

        columns.push(value)
      end

      xls_worksheet.insert_row(current_row, columns)

      current_row += 1
    end

    file = Tempfile.new('checklist')

    xls_workbook.write(file.path)
    file.rewind

    result = file.read

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

  def self.from_file(input, headers = DEFAULT_HEADERS, file_has_header = false)
    result              = false

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
  # Description: This imports data from an XLSX file into the Checklist Items
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def self.from_xlsx_filename(input_filename,
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

        checklist_item = find_or_create_checklist_item_by_id(columns, headers)

        return result unless checklist_item.present?

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name    = if index < headers.length
                               headers[index]
                             else
                               nil
                             end

            if column_name.present?
              result       = assign_column(checklist_item,
                                           column_name,
                                           column)
            end

            break unless result
          end

          result = DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                                checklist_item.id.present? ? 'update' : 'create',
                                                                checklist_item.id,
                                                                'checklist_items', 
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

  # Method:      from_patmos_spreadsheet
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
  # Description: This imports data from an XLSX file into the Checklist Items
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def self.from_patmos_spreadsheet(input_filename,
                                   review_id,
                                   headers_DO_178  = PATMOS_178_HEADER,
                                   headers_DO_254  = PATMOS_254_HEADER,
                                   headers_generic = GENERIC_HEADER)
    sheet_number                = 0
    result                      = nil
    session_id                  = nil
    xlsx_workbook               = Roo::Excelx.new(input_filename)

    xlsx_workbook.sheets.each do |xlsx_worksheet|
      first_row                 = xlsx_workbook.first_row(xlsx_worksheet)
      last_row                  = xlsx_workbook.last_row(xlsx_worksheet)
      columns                   = []
      first_column              = nil
      found                     = false
      supplements_present       = false

      next if first_row.nil?                          ||
              last_row.nil?                           ||
              xlsx_worksheet =~ /^\s*disclaimer\s*$/i ||
              xlsx_worksheet =~ /^\s*revisions\s*$/i  ||
              xlsx_worksheet =~ /^\s*revisions\s*$/i  ||
              xlsx_worksheet =~ /^\s*read\s*me\s*$/i

      sheet_number             += 1

      while (first_row < last_row) && !found
        columns                 = xlsx_workbook.row(first_row, xlsx_worksheet)

        columns.each_with_index do |cell, index|
          next unless cell.present?

          found                 = (cell.to_s == headers_DO_178[0])
          supplements_present   = true if (cell.to_s == 'Supplements')

          if found
            first_column        = index

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

        first_row              += 1

        break if found
      end

      next unless found

      for row in first_row...(last_row + 1) do
        row_columns             = xlsx_workbook.row(row, xlsx_worksheet)

        next if (row_columns.length < (first_column + 2)) ||
                 row_columns[first_column].nil?

        minimumdal              = ''
        supplements             = ''

        if row_columns[first_column + 3] == 'X'
          minimumdal           += 'A' 
        end

        if row_columns[first_column + 4] == 'X'
          minimumdal           += minimumdal.present? ? ',B' : 'B'
        end

        if row_columns[first_column + 5] == 'X'
          minimumdal           += minimumdal.present? ? ',C' : 'C'
        end

        if row_columns[first_column + 6] == 'X'
          minimumdal           += minimumdal.present? ? ',D' : 'D'
        end

        if supplements_present
          if row_columns[first_column + 7] == 'X'
            supplements        += 'Model Based' 
          end

          if row_columns[first_column + 8] == 'X'
            supplements        += supplements.present? ? ',Object Oriented' : 'Object Oriented'
          end

          if row_columns[first_column + 9] == 'X'
            supplements        += supplements.present?  ? ',Formal Method' : 'Formal Method'
          end
        end

        checklist_item = find_or_create_checklist_item_by_id([ row_columns[first_column] ],
                                                             [ 'clitemid' ])

        return result unless checklist_item.present?

        result                  = assign_column(checklist_item,
                                                'clitemid',
                                                row_columns[first_column].to_s)

        return result unless result

        return result unless result

        result                  = assign_column(checklist_item,
                                                'description',
                                                row_columns[first_column + 1])

        return result unless result

        result                  = assign_column(checklist_item,
                                                'reference',
                                                row_columns[first_column + 2])

        return result unless result

        result                  = assign_column(checklist_item,
                                                'minimumdal',
                                                minimumdal)

        return result unless result

        result                  = assign_column(checklist_item,
                                                'supplements',
                                                supplements)

        return result unless result

        checklist_item.review_id = review_id
        result = DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                              checklist_item.id.present? ? 'update' : 'create',
                                                              checklist_item.id,
                                                              'checklist_items', 
                                                              session_id)
        if result.present?
          session_id            = result.session_id
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
  # Description: This imports data from an XLS file into the Checklist Items.
  # Calls:       find_or_create_requirement_by_id, assign_column
  # Notes:       If the requirement already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-23-2019 - First Written, PC

  def self.from_xls_filename(input_filename,
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

      for row in first_row...last_row do
        columns                        = []
        column_number                  = 0

        for current_col in first_column..last_column
          columns[column_number]       = xls_worksheet.cell(row, current_col)
          columns[column_number]       = columns[column_number].to_s if columns[column_number].present?
          column_number               += 1        
        end

        checklist_item = find_or_create_checklist_item_by_id(columns, headers)

        return result unless checklist_item.present?

        unless columns.empty?
          columns.each_with_index do |column, index|
            column_name                = if index < headers.length
                                           headers[index]
                                         else
                                           nil
                                         end

            if column_name.present?
              result              = assign_column(checklist_item,
                                                  column_name,
                                                  column)
            end

            break unless result
          end

          result = DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                                checklist_item.id.present? ? 'update' : 'create',
                                                                checklist_item.id,
                                                                'checklist_items', 
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

  def self.from_csv_filename(filename,
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

  def self.from_csv_io(file, headers = DEFAULT_HEADERS)
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
  # Description: This imports data from a CSV file into the check list.
  # Calls:       find_or_create_checklist item_by_id, assign_column
  # Notes:       If the checklist item already exists it is replaced otherwise it
  #              is created and added in this case if the id doesn't exist it
  #              is one greater than the last checklist item id.
  # History:     09-06-2019 - First Written, PC

  def self.from_csv_string(line, headers = DEFAULT_HEADERS, session_id = nil)
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

    checklist_item = find_or_create_checklist_item_by_id(columns, headers)

    if checklist_item.present?
      columns.each_with_index do |value, index|
        column_name         = if index < headers.length
                                headers[index]
                              else
                                nil
                              end

        result              = assign_column(checklist_item,
                                            column_name,
                                            value) if column_name.present?

        break unless result
      end

      result                = DataChange.save_or_destroy_with_undo_session(checklist_item,
                                                                           checklist_item.id.present? ? 'update' : 'create',
                                                                           checklist_item.id, 'checklist_items', 
                                                                           session_id)
    end

    return result
  end

  # Method:      assign_column
  # Parameters:  checklist_item a ChecklistItem,
  #              the item to assign the column to.
  #
  #              column_name a String,
  #              The name of the column to be assigned.
  #
  #              value an object,
  #              The value to set the column to.
  #              
  # Return:      A Boolean, true if the value was assigned false otherwise.
  # Description: Assigns a valiue to a specic value in the ChecklistItem
  # Calls:       None
  # Notes:       
  # History:     09-06-2019 - First Written, PC

  def self.assign_column(checklist_item, column_name, value)
    result                           = false

    case column_name
      when 'clitemid'
        if value =~ /^\d+\.*\d*$/
          checklist_item.clitemid    = value.to_i
          result                     = true
        elsif value.nil?
          result                     = true
        end
      when 'title'
        checklist_item.title         = value
        result                       = true
      when 'description'
        checklist_item.description   = value
        result                       = true
      when 'note'
        checklist_item.note          = value
        result                       = true
      when 'review_id'
        review_id                    = nil

        if value.present?
          review                     = if value =~ /^\d+\.*\d*$/
                                         Review.find_by(id: value.to_i)
                                       else
                                         Review.find_by(title: value)
                                       end

          review_id                  = review.id if review.present?
        end

        checklist_item.review_id     = review_id
        result                       = true
      when 'document_id'
        document_id                  = nil

        if value.present?
          document                   = if value =~ /^\d+\.*\d*$/
                                         Document.find_by(id: value.to_i)
                                       else
                                         Document.find_by(name: value)
                                       end

          document_id                = document.id if document.present?
        end

        checklist_item.document_id   = document_id
        result                       = true
      when 'reference'
        checklist_item.reference     = value
        result                       = true
      when 'minimumdal'
        if value.present?
          value.gsub!('[', '');
          value.gsub!(']', '');
          value.gsub!('"', '');
          value.gsub!("'", '');
          value.gsub!(' ', '');
  
          checklist_item.minimumdal  = value.split(',')
        end

        result                       = true
      when 'supplements'
        if value.present?
          value.gsub!('[', '');
          value.gsub!(']', '');
          value.gsub!('"', '');
          value.gsub!("'", '');

          checklist_item.supplements = value.split(',')
        end

        result                       = true
      when 'status'
        checklist_item.status        = value
        result                       = true
      when 'evaluator'
        checklist_item.evaluator     = value
        result                       = true
      when 'evaluation_date'
        if value.present?
          begin
            self.target_date     = DateTime.parse(value)
            result               = true
          rescue
            result               = false
          end
        else
          result                 = true
        end
      when 'archive_revision'
        checklist_item.archive_revision = value
        result                          = true
      when 'archive_version'
        checklist_item.archive_version  = value.to_f if value.present?
        result                          = true
    end
  end

  # Method:      find_or_create_checklist_item_by_id
  # Parameters:  columns an array of strings,
  #              the Columns from the CSV file (used to get the clitemid).
  #
  #              headers an optional array of strings (default:DEFAULT_HEADERS),
  #              The headers for the CSV file.
  #              
  # Return:      A Checklist Item Object.
  # Description: Finds or Creates a Checklist Item Object by the ID in the line.
  # Calls:       None
  # Notes:       If the requirement already exists it is returned otherwise a
  #              a new one is created. In this case, if the id doesn't exist it
  #              is one greater than the last requirement id.
  # History:     09-06-2019 - First Written, PC

  def self.find_or_create_checklist_item_by_id(columns,
                                               headers = DEFAULT_HEADERS)
    id_at                         = headers.find_index('clitemid')
    review_id_at                  = headers.find_index('review_id')
    evaluator_at                  = headers.find_index('evaluator')
    checklist_item_id             = columns[id_at].to_i        if id_at.present? &&
                                                                  columns[id_at] =~ /^\d+\.*\d*$/
    review_id                     = columns[review_id_at].to_i if review_id_at.present? &&
                                                                  columns[review_id_at] =~ /^\d+\.*\d*$/
    evaluator                     = columns[evaluator_at]      if evaluator_at.present?

    if checklist_item_id.present? && review_id.present? && evaluator.present?
      checklist_item              = ChecklistItem.find_by(clitemid:     checklist_item_id,
                                                          review_id:    review_id,
                                                          evaluator:    evaluator)
    else
      last_id                     = nil
      checklist_items             = if review_id.present? && evaluator.present?
                                      ChecklistItem.where(review_id:    review_id,
                                                          evaluator:    evaluator,
                                                          organization: User.current.organization).order("clitemid")
                                    elsif review_id.present?
                                      ChecklistItem.where(review_id:    review_id,
                                                          organization: User.current.organization).order("clitemid")
                                    else
                                      ChecklistItem.where(organization: User.current.organization).order("clitemid")
                                    end

      checklist_items.each do |item|
        if last_id.present? &&
           (last_id != (item.clitemid - 1)) # we found a hole.
          checklist_item_id       = last_id + 1

          break;
        end

        last_id                   = item.clitemid
      end

      checklist_item_id           = if checklist_item_id.present?
                                      checklist_item_id
                                    elsif last_id.present?
                                      last_id + 1
                                    else
                                      1
                                    end
    end

    unless checklist_item.present?
      checklist_item              = ChecklistItem.new()
      checklist_item.clitemid     = checklist_item_id
      checklist_item.review_id    = review_id
      checklist_item.evaluator    = evaluator
    end

    return checklist_item
  end
end
