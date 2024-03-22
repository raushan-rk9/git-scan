class FunctionItem < OrganizationRecord
  belongs_to :source_code

  validates :function_item_id, presence: true
  validates :full_id,          presence: true, allow_blank: false

  FUNCTION_DEFINITION       = /^\s*(([*a-z0-9_\[\]]+\s+)+[*a-z0-9_\[\]]+\s*\(.*\))\s*\{{0,1}\s*$/i
  START_FUNCTION_DEFINITION = /^\s*(([*a-z0-9_]+\s+)+[*a-z0-9_]+\s*\(.*[\),])\s*$/i
  END_FUNCTION_DEFINITION   = /\)\s*$/i
  FULL_FUNCTION_CALL        = /([a-z0-9_]+)\((.?)[,]{0,1}.*\).*;\s*$/i
  START_FUNCTION_CALL       = /([a-z0-9_]+)\((.+)[,]{0,1}\s*$/i
  END_FUNCTION_CALL         = /\)\s*;/i
  KEYWORDS                  = /^\s*(else|if|while|for|switch|case|return|exit)/
  EMBEDED_CALL              = /\.*\(\s*([a-z0-9_]+)\((.+?)\).*\)/

  def self.analyze_code(code, source_code, session_id = nil)
    result                                  = true
    lines                                   = code.split("\n")
    line_count                              = lines.length
    project_id                              = source_code.project_id
    item_id                                 = source_code.item_id
    source_code_id                          = source_code.id
    filename                                = source_code.get_filename
    line_number                             = 0
    function_line_number                    = 0
    call_line_number                        = 0
    calling_function                        = ''
    calling_parameters                      = ''
    called_by                               = nil
    function                                = ''
    function_parameters                     = ''
    function_id_number                      = FunctionItem.maximum(:function_item_id)
    function_id_number                       = 1                                          unless function_id_number.present?

    while (line_number < line_count) do
      if (lines[line_number] =~ /^\s*\/\/.*$/)
        line_number                        += 1
      elsif (lines[line_number] =~ /^\s*\/\*.*$/)
        line_number                        += 1

        while ((line_number < line_count) &&
               !(lines[line_number] =~ /^.*\*\/.*$/))
          line_number                      += 1
        end

        line_number                        += 1
      elsif (lines[line_number] =~ /^\s*#.*$/)
        line_number                        += 1
      elsif lines[line_number] =~ FUNCTION_DEFINITION && !(lines[line_number] =~ KEYWORDS)
        called_by                           = nil
        calling_function                    = Regexp.last_match(1)
        calling_parameters                  = Regexp.last_match(2)
        first_paren                         = lines[line_number].index('(')
        last_paren                          = lines[line_number].rindex(')')
        params                              = lines[line_number][first_paren..last_paren]    if first_paren.present? &&
                                                                                                last_paren.present?  &&
                                                                                                (last_paren > first_paren)
        function                            = lines[line_number][0..(first_paren - 1)].strip if first_paren.present?
        calling_function                    = function if function.present?
        calling_parameters                  = params   if params.present?
        function                            = nil
        function_parameters                 = nil
        function_id_number                 += 1
        function_item                       = FunctionItem.new
        function_item.function_item_id      = function_id_number
        function_item.full_id               = "#{source_code_id}:#{function_id_number}"
        function_item.project_id            = project_id
        function_item.item_id               = item_id
        function_item.source_code_id        = source_code_id
        function_item.filename              = filename
        function_item.calling_function      = calling_function
        function_item.calling_parameters    = calling_parameters
        function_item.called_by             = called_by
        call_line_number                    = line_number + 1
        calling_parameters                  = params if params.present?
        function_item.line_number           = call_line_number
        function_item.function              = function
        function_item.function_parameters   = function_parameters
        existing_function_item              = FunctionItem.find_by(source_code_id: function_item.source_code_id,
                                                                   filename:       function_item.filename,
                                                                   line_number:    function_item.line_number)
        existing_function_item.destroy                                                    if existing_function_item.present?
        data_change                         = DataChange.save_or_destroy_with_undo_session(function_item,
                                                                                           'create',
                                                                                            nil,
                                                                                           'function_items',
                                                                                           session_id)
        session_id                          = data_change.session_id                      if data_change.present?
        called_by                           = function_item.id
        line_number                        += 1
      elsif lines[line_number] =~ FULL_FUNCTION_CALL && !(lines[line_number] =~ /^\s*exit\s*\(\d+\)\;/i) && !(lines[line_number] =~ /^\s*return\s*\(\d+\)\;/i)
        start_function                      = 0
        first_paren                         = lines[line_number].index('(')
        last_paren                          = lines[line_number].rindex(')')

        if first_paren > 0
          start_function                    = first_paren - 1

          while (start_function >= 0) && (lines[line_number][start_function] =~ /[*A-Za-z0-9_]/i)
            start_function -= 1
          end

          start_function += 1 if start_function != 0
        end

        params                              = lines[line_number][first_paren..last_paren]    if first_paren.present? &&
                                                                                                last_paren.present?  &&
                                                                                                (last_paren > first_paren)
        function                            = lines[line_number][start_function..(first_paren - 1)].strip if first_paren.present?
        function_parameters                 = params   if params.present?
        function_id_number                 += 1
        function                            = Regexp.last_match(1)                        unless function.present?
        function_parameters                 = Regexp.last_match(2)                        unless function_parameters.present?
        function_parameters                 = params if params.present?
        function_line_number                = line_number + 1
        function_item                       = FunctionItem.new
        function_item.calling_function      = calling_function
        function_item.calling_parameters    = calling_parameters
        function_item.function_item_id      = function_id_number
        function_item.full_id               = "#{source_code_id}:#{function_id_number}"
        function_item.project_id            = project_id
        function_item.item_id               = item_id
        function_item.source_code_id        = source_code_id
        function_item.filename              = filename
        function_item.function              = function
        function_item.function_parameters   = function_parameters
        function_item.line_number           = function_line_number
        function_item.called_by             = called_by
        existing_function_item              = FunctionItem.find_by(source_code_id: function_item.source_code_id,
                                                                   filename:       function_item.filename,
                                                                   line_number:    function_item.line_number)
        existing_function_item.destroy                                                    if existing_function_item.present?
        data_change                         = DataChange.save_or_destroy_with_undo_session(function_item,
                                                                                           'create',
                                                                                            nil,
                                                                                           'function_items',
                                                                                           session_id)
        session_id                          = data_change.session_id                      if data_change.present?
        line_number                        += 1
      elsif lines[line_number] =~ START_FUNCTION_DEFINITION && !(lines[line_number] =~ KEYWORDS)
        called_by                           = nil
        function_id_number                 += 1
        call_line_number                    = line_number + 1
        block                               = lines[line_number]
        line_number                        += 1

        while (line_number < line_count) do
          block                            += lines[line_number]
          line_number                      += 1

          break                                                                           if (lines[line_number - 1] =~ END_FUNCTION_DEFINITION) 
        end  


        block.gsub!("\n", ' ')
        block.gsub!("\r", '')

        while block.index('  ').present?
          block.gsub!('  ', ' ')
        end

        first_paren                         = block.index('(')
        last_paren                          = block.rindex(')')
        params                              = block[first_paren..last_paren]              if first_paren.present? &&
                                                                                             last_paren.present?  &&
                                                                                             (last_paren > first_paren)
        function                            = block[0..(first_paren - 1)].strip           if first_paren.present?
        calling_function                    = function                                    if function.present?
        calling_parameters                  = params                                      if params.present?
        function                            = nil
        function_parameters                 = nil
        function_item                       = FunctionItem.new
        function_item.function_item_id      = function_id_number
        function_item.full_id               = "#{source_code_id}:#{function_id_number}"
        function_item.project_id            = project_id
        function_item.item_id               = item_id
        function_item.source_code_id        = source_code_id
        function_item.filename              = filename
        function_item.calling_function      = calling_function
        function_item.calling_parameters    = calling_parameters
        function_item.called_by             = called_by
        call_line_number                    = line_number + 1
        function_item.line_number           = call_line_number
        function_item.function              = function
        function_item.function_parameters   = function_parameters
        existing_function_item              = FunctionItem.find_by(source_code_id: function_item.source_code_id,
                                                                   filename:       function_item.filename,
                                                                   line_number:    function_item.line_number)

        existing_function_item.destroy                                                  if existing_function_item.present?

        data_change                       = DataChange.save_or_destroy_with_undo_session(function_item,
                                                                                           'create',
                                                                                            nil,
                                                                                           'function_items',
                                                                                           session_id)
        session_id                          = data_change.session_id                    if data_change.present?
        called_by                           = function_item.id
        line_number                        += 1
      elsif lines[line_number] =~ START_FUNCTION_CALL && !(lines[line_number] =~ KEYWORDS) && !(lines[line_number] =~ /^\s*exit\s*\(\d+\)\;/i) && !(lines[line_number] =~ /^\s*return\s*\(\d+\)\;/i)
        function_id_number                 += 1
        function_line_number                = line_number + 1
        function                            = Regexp.last_match(1)
        function_parameters                 = Regexp.last_match(2)
        block                               = lines[line_number]
        line_number                        += 1

        while (line_number < line_count) do
          block                            += lines[line_number]
          line_number                      += 1

          break                                                                           if (lines[line_number - 1] =~ END_FUNCTION_CALL) 
        end

        block.gsub!("\n", ' ')
        block.gsub!("\r", '')

        while block.index('  ').present?
          block.gsub!('  ', ' ')
        end

        first_paren                         = block.index('(')
        last_paren                          = block.rindex(')')

        if first_paren > 0
          start_function                    = first_paren - 1

          while (start_function >= 0) && (block[start_function] =~ /[*A-Za-z0-9_]/i)
            start_function -= 1
          end

          start_function += 1 if start_function != 0
        end

        params                              = block[first_paren..last_paren]                       if first_paren.present? &&
                                                                                                     last_paren.present?  &&
                                                                                                     (last_paren > first_paren)
        function                            = block[start_function..(first_paren - 1)].strip                    if first_paren.present?
        function_parameters                 = params                                                if params.present?

        function_id_number                 += 1
        function_item                       = FunctionItem.new
        function_item.calling_function      = calling_function
        function_item.calling_parameters    = calling_parameters
        function_item.function_item_id      = function_id_number
        function_item.full_id               = "#{source_code_id}:#{function_id_number}"
        function_item.function_item_id      = function_id_number
        function_item.full_id               = "#{source_code_id}:#{function_id_number}"
        function_line_number                = function_line_number
        function_item.project_id            = project_id
        function_item.item_id               = item_id
        function_item.source_code_id        = source_code_id
        function_item.filename              = filename
        function_item.function              = function
        function_item.function_parameters   = function_parameters
        function_item.line_number           = function_line_number
        function_item.called_by             = called_by
        existing_function_item              = FunctionItem.find_by(source_code_id: function_item.source_code_id,
                                                                   filename:       function_item.filename,
                                                                   line_number:    function_item.line_number)
        existing_function_item.destroy                                                  if existing_function_item.present?
        data_change                         = DataChange.save_or_destroy_with_undo_session(function_item,
                                                                                           'create',
                                                                                            nil,
                                                                                           'function_items',
                                                                                           session_id)
        session_id                          = data_change.session_id                       if data_change.present?
        line_number                        += 1
      elsif lines[line_number] =~ EMBEDED_CALL
        function                            = Regexp.last_match(1)
        params                              = Regexp.last_match(2)
        function_parameters                 = params   if params.present?
        function_id_number                 += 1
        function                            = Regexp.last_match(1)
        function_parameters                 = Regexp.last_match(2)
        function_parameters                 = params if params.present?
        function_line_number                = line_number + 1
        function_item                       = FunctionItem.new
        function_item.calling_function      = calling_function
        function_item.calling_parameters    = calling_parameters
        function_item.function_item_id      = function_id_number
        function_item.full_id               = "#{source_code_id}:#{function_id_number}"
        function_item.project_id            = project_id
        function_item.item_id               = item_id
        function_item.source_code_id        = source_code_id
        function_item.filename              = filename
        function_item.function              = function
        function_item.function_parameters   = function_parameters
        function_item.line_number           = function_line_number
        function_item.called_by             = called_by
        existing_function_item              = FunctionItem.find_by(source_code_id: function_item.source_code_id,
                                                                   filename:       function_item.filename,
                                                                   line_number:    function_item.line_number)
        existing_function_item.destroy                                                    if existing_function_item.present?
        data_change                         = DataChange.save_or_destroy_with_undo_session(function_item,
                                                                                           'create',
                                                                                            nil,
                                                                                           'function_items',
                                                                                           session_id)
        session_id                          = data_change.session_id                      if data_change.present?
        line_number                        += 1
      else
        line_number                        += 1
      end

      params                                = nil
    end

    return result
  end

  def self.associate_codes(id, id_type = :item, session_id = nil)
    result                                                = false
    calling_functions                                     = {}
    function_items                                        = if id_type == :item
                                                              FunctionItem.where(item_id:      id,
                                                                                 organization: User.current.organization)
                                                            elsif id_type == :project
                                                              FunctionItem.where(project_id:   id,
                                                                                 organization: User.current.organization)
                                                            else
                                                              FunctionItem.where(organization: User.current.organization)
                                                            end

    function_items.each do |function_item|
      next if function_item.called_by.present?    ||
              function_item.function.nil?         ||
              function_item.calling_function.nil?

      if calling_functions[function_item.calling_function].present?
        function_item.called_by                           = calling_functions[function_item.calling_function]
      else
        calling_function                                  = if id_type == :item
                                                              FunctionItem.find_by(item_id:          id,
                                                                                   calling_function: function_item.calling_function,
                                                                                   organization:     User.current.organization)
                                                            elsif id_type == :project
                                                              FunctionItem.find_by(project_id:       id,
                                                                                   calling_function: function_item.calling_function,
                                                                                   organization:     User.current.organization)
                                                            else
                                                              FunctionItem.find_by(calling_function: function_item.calling_function,
                                                                                   organization:     User.current.organization)
                                                            end

        next unless calling_function.present?

        function_item.called_by                           = calling_function.id
        calling_functions[function_item.calling_function] = calling_function.id
      end

      data_change                                         = DataChange.save_or_destroy_with_undo_session(function_item,
                                                                                                         'update',
                                                                                                         function_item.id,
                                                                                                         'function_items',
                                                                                                         session_id)
      if data_change.present?
        session_id                                        = data_change.session_id if data_change.present?
        result                                            = true
      end
    end if function_items.present?

    return result
  end
end
