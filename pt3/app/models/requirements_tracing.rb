class RequirementsTracing < OrganizationRecord
  def new
    raise "Associations should never be instantiated."
  end

public
  def self.sort_on_full_id(items)
    begin
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
      end if items.present?
    rescue
    end
  end

  def self.session
    Thread.current[:session]
  end

  def self.session=(session)
    Thread.current[:session] = session
  end

  def self.get_archive_id
    result = if self.session[:archives_visible].kind_of?(Integer) &&
                self.session[:archived_project].kind_of?(Integer)
               self.session[:archives_visible]
             elsif self.session[:archived_project]
               self.session[:archived_project]
             else
               nil
             end

    return result
  end

  def self.get_display_name(table_name, item_id = nil)
    result = ''

    case(table_name)
      when 'system_requirements'
        result = I18n.t('misc.system_requirements')
      when 'high_level_requirements'
        result = Item.item_type_title(item_id, :high_level, :plural)
      when 'low_level_requirements'
        result = Item.item_type_title(item_id, :low_level, :plural)
      when 'test_cases'
        result = I18n.t('misc.test_cases')
      when 'test_procedures'
        result = I18n.t('misc.test_procedures')
      when 'module_descriptions'
        result = I18n.t('module_description.pl_title')
      when 'source_code', 'source_codes'
        result = I18n.t('misc.source_code')
    end
  end

  def self.get_derived_requirements(table_name,
                                    project_id   = nil,
                                    item_id      = nil,
                                    organization = User.current.organization)
    if (table_name == 'system_requirements')
      if item_id.present?
        requirements = SystemRequirement.where(project_id:   project_id,
                                               organization: organization,
                                               derived:      true,
                                               archive_id:   self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if do |requirement|
          included   = false
          hlrs       = requirement.high_level_requirements

          hlrs.each do |hlr|
            included = (hlr.item_id == item_id)

            break if included
          end

          !included
        end if item_id.present?
      else
        requirements = SystemRequirement.where(project_id:   project_id,
                                               organization: organization,
                                               derived:      true,
                                               archive_id:   self.get_archive_id()).to_a
      end
    else
      if (table_name != 'test_procedures') && (table_name != 'module_descriptions') 
        requirements = table_name.singularize.classify.constantize.where(item_id:      item_id,
                                                                         organization: organization,
                                                                         derived:      true,
                                                                         archive_id:   self.get_archive_id()).to_a
      end
    end

    return requirements
  end

  def self.get_unlinked_requirements(table_name,
                                     item_id      = nil,
                                     organization = User.current.organization)
    requirements     = []

    case(table_name)
      when 'high_level_requirements'
        requirements = HighLevelRequirement.where(item_id:      item_id,
                                                  organization: organization,
                                                  archive_id:   self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |hlr| hlr.system_requirement_associations.present? || hlr.high_level_requirement_associations.present? }
      when 'low_level_requirements'
        requirements = LowLevelRequirement.where(item_id:       item_id,
                                                 organization:  organization,
                                                 archive_id:    self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |llr| llr.high_level_requirement_associations.present? }
      when 'test_cases'
        requirements = TestCase.where(item_id:                  item_id,
                                      organization:             organization,
                                      archive_id:               self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |tc| tc.high_level_requirement_associations.present? || tc.low_level_requirement_associations.present?}
      when 'test_procedures'
        requirements = TestProcedure.where(item_id:             item_id,
                                           organization:        organization,
                                           archive_id:          self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |tp| tp.test_case_associations.present? }
      when 'module_descriptions'
        requirements = ModuleDescription.where(item_id:         item_id,
                                               organization:    organization,
                                               archive_id:      self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |md| md.low_level_requirement_associations.present?}
      when 'source_codes', 'source_code'
        requirements = SourceCode.where(item_id:                item_id,
                                        organization:           organization,
                                        archive_id:             self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |sc| sc.module_description_associations.present? }
    end

    return requirements
  end

  def self.get_unallocated_requirements(table_name,
                                        project_id   = nil,
                                        item_id      = nil,
                                        organization = User.current.organization)
    requirements     = []

    case(table_name)
      when 'system_requirements'
        requirements = SystemRequirement.where(project_id:      project_id,
                                               organization: organization,
                                               archive_id:   self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |sysreq| sysreq.high_level_requirements.present? }
      when 'high_level_requirements'
        requirements = HighLevelRequirement.where(item_id:      item_id,
                                                  organization: organization,
                                                  archive_id:   self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |hlr| hlr.low_level_requirements.present? || hlr.high_level_requirements.present? || hlr.low_level_requirements.present? || hlr.test_cases.present? }
      when 'low_level_requirements'
        requirements = LowLevelRequirement.where(item_id:       item_id,
                                                 organization:  organization,
                                                 archive_id:    self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |llr| llr.module_descriptions.present? || llr.test_cases.present?  }
      when 'test_cases'
        requirements = TestCase.where(item_id:                  item_id,
                                      organization:             organization,
                                      archive_id:               self.get_archive_id()).order(:full_id).to_a
        requirements = requirements.delete_if { |tc| tc.test_procedures.present? }
    end

    return requirements
  end

  def self.get_table_rows(table_name, ids)
    rows       = []
    ids        = ids.split(',') if ids.kind_of?(String)
    archive_id = self.get_archive_id()

    ids.each do |id|
      next unless id.present?

      item = table_name.singularize.classify.constantize.find_by(id: id.to_i)

      next unless item.present?

      rows.push(item)
    end if ids.present?

    rows.delete_if {  |row| row.archive_id != archive_id } if rows.present?

    rows       = self.sort_on_full_id(rows) if rows.present?

    return rows
  end

  def self.get_parent_requirements(child_object, parent_table_name)
    requirements         = []

    case(child_object.class.name.tableize)
      when 'high_level_requirements'
        case parent_table_name
          when 'system_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.system_requirement_associations)

          when 'high_level_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.high_level_requirement_associations)
        end

      when 'low_level_requirements'
        case parent_table_name
          when 'high_level_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.high_level_requirement_associations)
        end

      when 'module_descriptions'
        case parent_table_name
          when 'high_level_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.high_level_requirement_associations)
          when 'low_level_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.low_level_requirement_associations)
        end

      when 'source_code', 'source_codes'
        case parent_table_name
          when 'module_descriptions'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.module_description_associations)
        end

      when 'test_cases'
        case parent_table_name
          when 'high_level_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.high_level_requirement_associations)

          when 'low_level_requirements'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.low_level_requirement_associations)
        end

      when 'test_procedures'
        case parent_table_name
          when 'test_cases'
            requirements = self.get_table_rows(parent_table_name,
                                               child_object.test_case_associations)
        end
    end

    return requirements
  end

  def self.get_sibling_requirements(sibling_object, sibling_table_name)
    result               = []
    requirements         = nil
    archive_id           = self.get_archive_id()

    case(sibling_object.class.name.tableize)
      when 'high_level_requirements'
        case sibling_table_name
          when 'high_level_requirements'
            requirements = sibling_object.high_level_requirements.to_a
        end
    end

    requirements.delete_if {  |req| req.archive_id != archive_id } if requirements.present?

    result               = self.sort_on_full_id(requirements) if requirements.present?

    return result
  end

  def self.get_child_requirements(parent_object, child_table_name, item_id = nil)
    requirements         = []
    archive_id           = self.get_archive_id()

    case(parent_object.class.name.tableize)
      when 'system_requirements'
        case child_table_name
          when 'high_level_requirements'
            requirements = parent_object.high_level_requirements.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?
        end

      when 'high_level_requirements'
        case child_table_name
          when 'low_level_requirements'
            requirements = parent_object.low_level_requirements.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?

          when 'module_descriptions'
            requirements = parent_object.module_descriptions.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?

          when 'source_code', 'source_codes'
            requirements = parent_object.source_codes.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?

          when 'test_cases'
            requirements = parent_object.test_cases.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?
        end

      when 'low_level_requirements'
        case child_table_name
          when 'module_descriptions'
            requirements = parent_object.module_descriptions.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?

          when 'test_cases'
            requirements = parent_object.test_cases.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?
        end

      when 'module_descriptions'
        case child_table_name
          when 'source_code', 'source_codes'
            requirements = parent_object.source_codes.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?
        end

      when 'test_cases'
        if child_table_name == 'test_procedures'
          requirements   = parent_object.test_procedures.to_a
            requirements = requirements.delete_if do |requirement|
                             requirement.item_id != item_id
                           end if item_id.present?
        end
    end

    requirements.delete_if {  |req| req.archive_id != archive_id } if requirements.present?

    requirements         = self.sort_on_full_id(requirements) if requirements.present?

    return requirements
  end

  def self.get_base_requirements(table_name,
                                 project_id   = nil,
                                 item_id      = nil,
                                 organization = User.current.organization)
    requirements                = []

    if (table_name == 'system_requirements')
      if item_id.present?
        system_requirements     = {}
        high_level_requirements = HighLevelRequirement.where(project_id:   project_id,
                                                             item_id:      item_id,
                                                             organization: organization,
                                                             archive_id:   self.get_archive_id()).to_a

        high_level_requirements.each do |high_level_requirement|
          sysreqs               = get_parent_requirements(high_level_requirement,
                                                          'system_requirements')

          sysreqs.each { |sysreq| system_requirements[sysreq.id] = sysreq } if sysreqs.present?
        end if high_level_requirements

        system_requirements.each { |id, sysreq| requirements.push(sysreq) } if system_requirements.present?
      else
        requirements            = SystemRequirement.where(project_id:   project_id,
                                                          organization: organization,
                                                          archive_id:   self.get_archive_id()).to_a
      end
    else
      requirements              = table_name.singularize.classify.constantize.where(item_id:      item_id,
                                                                                    organization: organization,
                                                                                    archive_id:   self.get_archive_id()).to_a
    end

    requirements                = self.sort_on_full_id(requirements) if requirements.present?

    return requirements
  end

  def self.add_siblings(requirements_list,
                        matrix,
                        sibling_column,
                        requirement_name,
                        new_matrix = [])
    sibling_items                        = {}
    columns                              = 0

    matrix.each do |row|
      siblings                           = self.get_sibling_requirements(row[sibling_column],
                                                                         requirement_name)

      next unless siblings.present?

      siblings.each do |sibling|
        unless sibling_items[sibling.item_id].present?
          sibling_items[sibling.item_id] = columns
          columns                       += 1

          if (sibling_column + columns) >= requirements_list.length
            requirements_list.push(Item.identifier_from_id(sibling.item_id) +
                                   ' ' +
                                   requirements_list[sibling_column])
          else
            requirements_list            = requirements_list.insert((sibling_column + columns),
                                                                    Item.identifier_from_id(sibling.item_id) +
                                                                    ' ' +
                                                                    requirements_list[sibling_column])
          end
        end
      end
    end

    return matrix if columns == 0

    sibling_columns                      = []

    (0..(columns - 1)).each { sibling_columns.push(nil) }

    matrix.each do |row|
      row_before                         = if sibling_column > 0
                                             row[0..sibling_column]
                                           elsif sibling_column == 0
                                             [ row[0] ]
                                           else
                                             []
                                           end
      row_after                          = if sibling_column < row.length
                                             row[(sibling_column + 1)..(row.length - 1)]
                                           else
                                             []
                                           end
      siblings                           = self.get_sibling_requirements(row[sibling_column],
                                                                         requirement_name)

      if siblings.empty?
        new_matrix.push(row_before + sibling_columns + row_after)
      else
        siblings.each do |sibling|
          column                         = sibling_items[sibling.item_id]
          columns                        = sibling_columns.dup
          columns[column]                = sibling

          new_matrix.push(row_before + columns + row_after)
        end
      end
    end

    return new_matrix
  end

  def self.add_children(requirements_list,
                        matrix,
                        parent_column,
                        child_column,
                        requirement_name,
                        reversed           = false,
                        project_id         = nil,
                        item_id            = nil,
                        new_matrix         = [])
    child_items                            = {}
    first_child                            = true
    columns                                = 0
    new_matrix                             = []


    if !reversed &&
        (requirement_name == 'high_level_requirements') &&
        (matrix.length    == 0)                         &&
        (child_column     == 1)                         &&
        item_id.present?
      # There are no SysReqs

      hlrs = HighLevelRequirement.where(item_id:      item_id,
                                        organization: User.current.organization)

      hlrs.each { |hlr| new_matrix.push([ nil ,  hlr ]) }
    end

    matrix.each do |row|
      parent_requirement                   = row[parent_column]
      children                             = if reversed
                                               self.get_parent_requirements(parent_requirement,
                                                                            requirement_name)
                                             else
                                               self.get_child_requirements(parent_requirement,
                                                                           requirement_name,
                                                                           item_id)
                                             end

      if children.empty?
        new_matrix.push(row.clone)
      else
        children.each_with_index do |child, child_index|
          insert_column                    = child_column

          if !item_id.present? && child.respond_to?(:item_id)
            column                         = child_items[child.item_id]

            if !column.present?
              if first_child
                first_child                = false
                insert_column              = child_column
                child_items[child.item_id] = child_column
              else
                columns                   += 1
                insert_column              = child_column + columns
                child_items[child.item_id] = insert_column

                if (child_column + columns) >= requirements_list.length
                  requirements_list.push(Item.identifier_from_id(child.item_id) +
                                         ' ' +
                                         requirements_list[child_column])
                else
                  requirements_list        = requirements_list.insert((child_column + columns),
                                                                      Item.identifier_from_id(child.item_id) +
                                                                      ' ' +
                                                                      requirements_list[child_column])
                end

                insert_column              = child_column + columns
              end
            else
              insert_column                = column
            end
          end

          if row[insert_column].present?
            new_matrix.push(row.clone)
          end

          new_row                = row.clone
          new_row[insert_column] = child

          new_matrix.push(new_row)
        end
      end
    end

    if requirement_name == 'high_level_requirements'
      new_matrix                = self.add_siblings(requirements_list,
                                                    new_matrix,
                                                    child_column,
                                                    'high_level_requirements')
    end

    return new_matrix
  end

  def self.generate_specialized_hash(requirements_list,
                                     matrix_type  = :derived,
                                     project_id   = nil,
                                     item_id      = nil,
                                     organization = User.current.organization)
    result                     = {}

    if requirements_list.kind_of?(String)
      requirements_list        = requirements_list.split(',').delete_if do |requirement|
                                   if requirement == 'reversed'
                                     true
                                   else
                                     false
                                   end
                                 end
    end

    return result unless requirements_list.present? &&
                         (requirements_list.length > 0)

    requirements_list.each_with_index do |requirement_name, requirement_index|
      requirements             = []

      case(matrix_type)
        when :derived
          requirements         = self.get_derived_requirements(requirement_name,
                                                               project_id,
                                                               item_id,
                                                               organization)
        when :unlinked
          requirements         = self.get_unlinked_requirements(requirement_name,
                                                                item_id,
                                                                organization)
        when :unallocated
          requirements         = self.get_unallocated_requirements(requirement_name,
                                                                   project_id,
                                                                   item_id,
                                                                   organization)
      end

      result[requirement_name] = requirements if requirements.present?
    end

    return result
  end

  def self.generate_trace_matrix(requirements_list,
                                 reversed     = false,
                                 project_id   = nil,
                                 item_id      = nil,
                                 organization = User.current.organization)
    full_matrix              = []

    if requirements_list.kind_of?(String)
      requirements_list      = requirements_list.split(',').delete_if do |requirement|
                                 if requirement == 'reversed'
                                   reversed = true
                                 else
                                   false
                                 end
                               end
    end

    return full_matrix unless requirements_list.present? &&
                              (requirements_list.length > 0)

    requirement_index        = 0

    while requirement_index < requirements_list.length
      unless self.get_display_name(requirements_list[requirement_index]).present?
        requirement_index += 1
        next
      end

      old_list_length        = requirements_list.length
      requirement_name       = requirements_list[requirement_index]
      sysreq_column          = requirements_list.find_index('system_requirements')
      hlr_column             = requirements_list.find_index('high_level_requirements')
      llr_column             = requirements_list.find_index('low_level_requirements')
      md_column              = requirements_list.find_index('module_descriptions')
      sc_column              = requirements_list.find_index('source_code')
      sc_column              = requirements_list.find_index('source_codes') unless sc_column.present?
      tc_column              = requirements_list.find_index('test_cases')
      tp_column              = requirements_list.find_index('test_procedures')
      parent_index           = nil

      if requirement_index > 0
        if reversed
          case(requirement_name)
            when 'system_requirements'
              parent_index   = hlr_column
            when 'high_level_requirements'
              parent_index   = [ llr_column, tc_column, sc_column ]
            when 'low_level_requirements'
              parent_index   = [ tc_column, md_column ]
            when 'module_descriptions'
              parent_index   = llr_column
              parent_index   = [ hlr_column, llr_column ]
            when 'source_code', 'source_codes'
              parent_index   = md_column
            when 'test_cases'
              parent_index   = tp_column
            when 'test_procedures'
              parent_index   = nil
          end
        else
          case(requirement_name)
            when 'system_requirements'
              parent_index   = nil
            when 'high_level_requirements'
              parent_index   = sysreq_column
            when 'low_level_requirements'
              parent_index   = hlr_column
            when 'module_descriptions'
              parent_index   = [ hlr_column, llr_column ]
            when 'source_code', 'source_codes'
              parent_index   = md_column
            when 'test_cases'
              parent_index   = [ hlr_column, llr_column ]
            when 'test_procedures'
              parent_index   = tc_column
          end
        end
      end

      if requirement_index == 0
        requirements         = self.get_base_requirements(requirement_name,
                                                          project_id,
                                                          item_id,
                                                          organization)

        requirements.each { |requirement| full_matrix.push([ requirement ]) }

        if requirement_name == 'high_level_requirements'
          full_matrix        = self.add_siblings(requirements_list,
                                                 full_matrix,
                                                 0,
                                                 'high_level_requirements')
        end
      else
        if parent_index.kind_of?(Array)
          parent_index.each do |parent|
            next unless parent.present?

            full_matrix      = self.add_children(requirements_list,
                                                 full_matrix,
                                                 parent,
                                                 requirement_index,
                                                 requirement_name,
                                                 reversed,
                                                 project_id,
                                                 item_id)
          end
        else
          if parent_index.present?
            full_matrix      = self.add_children(requirements_list,
                                                 full_matrix,
                                                 parent_index,
                                                 requirement_index,
                                                 requirement_name,
                                                 reversed,
                                                 project_id,
                                                 item_id)
          else
            requirements     = self.get_base_requirements(requirement_name,
                                                          project_id,
                                                          item_id,
                                                          organization)

            requirements.each do |requirement|
              row            = []

              (0..(requirement_index - 1)).each { row.push(nil) }

              row.push(requirement)
              full_matrix.push(row)
            end
          end
        end
      end

      added_columns          = requirements_list.length - old_list_length
      requirement_index     += (added_columns + 1)
    end

    return sort_matrix(full_matrix)
  end

  def self.sort_matrix(matrix)
    matrix.sort do |row_1,row_2|
      index        = 0
      result       = nil
      row_1_length = row_1.length
      row_2_length = row_2.length

      while (index < row_1_length) && result.nil?
        result     = if      (index >= row_1_length)  || (index >= row_2_length)
                       if    (index >= row_1_length)  && (index <= row_2_length)
                         -1
                       elsif (index >= row_2_length)  && (index <= row_1_length)
                         1
                       else
                         0
                       end
                     elsif row_1[index].present? && row_2[index].present? &&
                           row_1[index].full_id  !=  row_2[index].full_id
                       row_1[index].full_id <=> row_2[index].full_id
                     end
        index     += 1 if result.nil?
      end

      result       = 0 if result.nil?

      result
    end if matrix.present?
  end

  def self.save_csv_spreadsheet(headers, matrix, item)
    CSV.generate(headers: true) do |csv|
      csv << headers

      matrix.each do |row|
        csv_row         = []

        row.each do |column|
          if column.present?
            description = Sanitize.fragment(column.description).gsub(/[\r]*\n/, ' ').gsub(/&nbsp;/i, ' ').gsub(/&.+;/, '').gsub(/[^[:print:]]/,'') if column.description.present?
            title       = Sanitize.fragment(column.full_id).gsub(/[\r]*\n/, ' ').gsub(/&nbsp;/i, ' ').gsub(/&.+;/, '').gsub(/[^[:print:]]/,'')

            if (column.class.name == 'ModuleDescription') || (column.class.name == 'SourceCode')
              csv_row.push("#{title}: #{description} - #{column.file_name}".gsub(/[^[:print:]]/,''))
            else
              csv_row.push("#{title}: #{description}".gsub(/[^[:print:]]/,''))
            end
          else
            csv_row.push('')
          end
        end

        csv << csv_row
      end
    end
  end

  def self.save_xls_spreadsheet(headers, matrix, item)
    xls_workbook      = Spreadsheet::Workbook.new
    xls_worksheet     = xls_workbook.create_worksheet

    xls_worksheet.insert_row(0, headers)

    matrix.each_with_index do |row, row_number|
      xls_row         = []

      row.each do |column|
        if column.present?
          description = Sanitize.fragment(column.description).gsub(/[\r]*\n/, ' ').gsub(/&nbsp;/i, ' ').gsub(/&.+;/, '').gsub(/[^[:print:]]/,'') if column.description.present?
          title       = Sanitize.fragment(column.full_id).gsub(/[\r]*\n/, ' ').gsub(/&nbsp;/i, ' ').gsub(/&.+;/, '').gsub(/[^[:print:]]/,'')

          if (column.class.name == 'ModuleDescription') || (column.class.name == 'SourceCode')
            xls_row.push("#{title}: #{description} - #{column.file_name}".gsub(/[^[:print:]]/,''))
          else
            xls_row.push("#{title}: #{description}".gsub(/[^[:print:]]/,''))
          end
        else
          xls_row.push('')
        end
      end

      xls_worksheet.insert_row((row_number + 1), xls_row)
    end

    file              = Tempfile.new('requirements-trace-matrix')

    xls_workbook.write(file.path)
    file.rewind

    result            = file.read

    file.close
    file.unlink

    return result
  end
end
