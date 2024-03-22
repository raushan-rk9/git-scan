class Associations < OrganizationRecord
  def new
    raise "Associations should never be instantiated."
  end

  def self.get_associations_as_full_ids(table_name,
                                        referring_table,
                                        parent_id,
                                        associations,
                                        as_string    = false,
                                        organization = User.current.organization)
    result = if table_name.present? && parent_id.present? && associations.present?
               associations.split(',').map do |id|
                 association   = if (table_name.singularize      == 'system_requirement') ||
                                    (referring_table.singularize == 'high_level_requirement')
                                   table_name.singularize.classify.constantize.find_by(project_id:   parent_id,
                                                                                       id:           id,
                                                                                       organization: organization)
                                 else
                                   table_name.singularize.classify.constantize.find_by(item_id:      parent_id,
                                                                                       id:           id,
                                                                                       organization: organization)
                                 end

                 if association.present?
                   association.full_id
                 else
                   if referring_table == 'model_files'
                     association = table_name.singularize.classify.constantize.find_by(project_id:   parent_id,
                                                                                       id:           id,
                                                                                       organization: organization)

                     if association.present?
                       association.full_id
                     end
                   else
                     nil
                   end
                 end
               end
             else
               []
             end

    result = result.join(',') if as_string

    return result
  end

  def self.set_associations_from_full_ids(table_name,
                                          referring_table,
                                          parent_id,
                                          associations,
                                          as_string    = false,
                                          organization = User.current.organization)
    associations = associations.split(',') if associations.kind_of?(String)
    result       = if table_name.present? && parent_id.present? && associations.present?
                     associations.map do |id|
                       association = if (table_name.singularize      == 'system_requirement') ||
                                        (referring_table.singularize == 'high_level_requirement')
                                       table_name.singularize.classify.constantize.find_by(project_id:   parent_id,
                                                                                           full_id:      id,
                                                                                           organization: organization)
                                     else
                                       table_name.singularize.classify.constantize.find_by(item_id:      parent_id,
                                                                                           full_id:      id,
                                                                                           organization: organization)
                                     end

                       if association.present?
                         association.id
                       else
                         if referring_table == 'model_files'
                           association = table_name.singularize.classify.constantize.find_by(project_id:   parent_id,
                                                                                             full_id:      id,
                                                                                             organization: organization)

                           if association.present?
                             association.id
                           end
                         else
                           nil
                         end
                       end
                     end
                   else
                     []
                   end

    result       = result.join(',') if as_string

    return result
  end

  def self.set_associations_hash(object)
    result                                = {}

    return result unless object.present?

    table_name                            = object.class.name.tableize

    case table_name
      when 'high_level_requirements'
        result['system_requirements']     = object.system_requirement_associations     if object.system_requirement_associations.present?
        result['high_level_requirements'] = object.high_level_requirement_associations if object.high_level_requirement_associations.present?
      when 'low_level_requirements'
        result['high_level_requirements'] = object.high_level_requirement_associations if object.high_level_requirement_associations.present?
      when 'model_files'
        result['system_requirements']     = object.system_requirement_associations     if object.system_requirement_associations.present?
        result['high_level_requirements'] = object.high_level_requirement_associations if object.high_level_requirement_associations.present?
        result['low_level_requirements']  = object.low_level_requirement_associations  if object.low_level_requirement_associations.present?
        result['test_cases']              = object.test_case_associations              if object.test_case_associations.present?
      when 'module_descriptions'
        result['high_level_requirements'] = object.high_level_requirement_associations if object.high_level_requirement_associations.present?
        result['low_level_requirements']  = object.low_level_requirement_associations  if object.low_level_requirement_associations.present?
      when 'source_codes'
        result['high_level_requirements'] = object.high_level_requirement_associations if object.high_level_requirement_associations.present?
        result['low_level_requirements']  = object.low_level_requirement_associations  if object.low_level_requirement_associations.present?
        result['module_descriptions']     = object.module_description_associations     if object.module_description_associations.present?
      when 'test_cases'
        result['high_level_requirements'] = object.high_level_requirement_associations if object.high_level_requirement_associations.present?
        result['low_level_requirements']  = object.low_level_requirement_associations  if object.low_level_requirement_associations.present?
      when 'test_procedures'
        result['test_cases']              = object.test_case_associations              if object.test_case_associations.present?
    end

    return result
  end

  def self.delete_associations(id, table, target_table, id_name)
    result = false

    return result unless id.present?           &&
                         table.present?        &&
                         target_table.present? &&
                         id_name.present?

    ActiveRecord::Base.connection.execute("DELETE FROM #{table}_#{target_table}s WHERE #{id_name}=#{id}") if id.present?

    result = true

    return result
  end

  def self.clear_associations(id, table_name, attributes = [])
    result   = false

    return result unless id.present? && table_name.present?

    case table_name
      when 'high_level_requirements', 'high_level_requirement', 'hlr'
        result = self.delete_associations(id,
                                          'sysreq',
                                          'hlr',
                                          'high_level_requirement_id') if !attributes.present? ||
                                                                           attributes.include?('system_requirement_associations')
        result = self.delete_associations(id,
                                          'hlr',
                                          'hlr',
                                          'high_level_requirement_id') if !attributes.present? ||
                                                                           attributes.include?('high_level_requirement_associations')

      when 'low_level_requirements', 'low_level_requirement', 'llr'
        result = self.delete_associations(id, 'hlr', 'llr',
                                          'low_level_requirement_id')

      when 'model_files', 'model_file', 'mf'
        result = self.delete_associations(id,
                                          'sysreq',
                                          'mf',
                                          'model_file_id') if !attributes.present? ||
                                                                           attributes.include?('system_requirement_associations')
        result = self.delete_associations(id,
                                          'hlr',
                                          'mf',
                                          'model_file_id') if !attributes.present? ||
                                                                           attributes.include?('high_level_requirement_associations')
        result = self.delete_associations(id,
                                          'llr',
                                          'mf',
                                          'model_file_id') if !attributes.present? ||
                                                                           attributes.include?('low_level_requirement_associations')
        result = self.delete_associations(id,
                                          'tc',
                                          'mf',
                                          'model_file_id') if !attributes.present? ||
                                                                           attributes.include?('test_case_associations')

      when 'module_descriptions', 'module_description', 'md'
        result = self.delete_associations(id,
                                          'hlr',
                                          'md',
                                          'module_description_id')  if !attributes.present?
                                                                        attributes.include?('high_level_requirement_associations')
        result = self.delete_associations(id,
                                          'llr',
                                          'md',
                                          'module_description_id') if !attributes.present? ||
                                                                      attributes.include?('low_level_requirement_associations')

      when 'source_codes', 'source_code', 'sc'
        result = self.delete_associations(id,
                                          'hlr',
                                          'sc',
                                          'source_code_id')  if !attributes.present?
                                                                attributes.include?('high_level_requirement_associations')
        result = self.delete_associations(id,
                                          'llr',
                                          'sc',
                                          'source_code_id') if !attributes.present? ||
                                                               attributes.include?('low_level_requirement_associations')
        result = self.delete_associations(id,
                                          'md',
                                          'sc',
                                          'source_code_id') if !attributes.present? ||
                                                               attributes.include?('module_description_associations')

      when 'test_cases', 'test_case', 'tc'
        result = self.delete_associations(id,
                                          'hlr',
                                          'tc',
                                          'test_case_id') if !attributes.present? ||
                                                              attributes.include?('high_level_requirement_associations')
        result = self.delete_associations(id,
                                          'llr',
                                          'tc',
                                          'test_case_id') if !attributes.present?
                                                              attributes.include?('low_level_requirement_associations')

      when 'test_procedures', 'test_procedure', 'tp'
        result = self.delete_associations(id, 'tcs',     'tp',  'test_procedure_id')
    end

    return result
  end

  def self.clear_association(object, attributes = [])
    return clear_associations(object.id, object.class.name.tableize, attributes)
  end

  def self.insert_association(id,
                              association_id,
                              table,
                              target_table,
                              id_name,
                              association_id_name)
    result = false

    return result unless id.present?           &&
                         table.present?        &&
                         target_table.present? &&
                         id_name.present?

    ActiveRecord::Base.connection.execute("INSERT INTO #{table}_#{target_table}s (#{association_id_name}, #{id_name}) VALUES (#{association_id}, #{id})")

    result = true

    return result
  end

  def self.set_association(id, association_id, table_name, attribute)
    result         = false

    return result unless id.present?             &&
                         association_id.present? &&
                         table_name.present?

    case table_name
      when 'high_level_requirements', 'high_level_requirement', 'hlr'
        case(attribute)
          when 'system_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'sysreq',
                                             'hlr',
                                             'high_level_requirement_id',
                                             'system_requirement_id')

          when 'high_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'hlr',
                                             'hlr',
                                             'high_level_requirement_id',
                                             'referenced_high_level_requirement_id')
        end

      when 'low_level_requirements', 'low_level_requirement', 'llr'
        result     = self.insert_association(id,
                                             association_id,
                                             'hlr',
                                             'llr',
                                             'low_level_requirement_id',
                                             'high_level_requirement_id')

      when 'model_files', 'model_file', 'mf'
        case(attribute)
          when 'system_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'sysreq',
                                             'mf',
                                             'model_file_id',
                                             'system_requirement_id')
          when 'high_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'hlr',
                                             'mf',
                                             'model_file_id',
                                             'high_level_requirement_id')
          when 'low_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'llr',
                                             'mf',
                                             'model_file_id',
                                             'low_level_requirement_id')
          when 'test_case_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'tc',
                                             'mf',
                                             'model_file_id',
                                             'test_case_id')
        end

      when 'module_descriptions', 'module_description', 'md'
        case(attribute)
          when 'high_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'hlr',
                                             'md',
                                             'module_description_id',
                                             'high_level_requirement_id')
          when 'low_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'llr',
                                             'md',
                                             'module_description_id',
                                             'low_level_requirement_id')
        end

      when 'source_codes', 'source_code', 'sc'
        case(attribute)
          when 'high_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'hlr',
                                             'sc',
                                             'source_code_id',
                                             'high_level_requirement_id')
          when 'low_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'llr',
                                             'sc',
                                             'source_code_id',
                                             'low_level_requirement_id')
          when 'module_description_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'md',
                                             'sc',
                                             'source_code_id',
                                             'module_description_id')
        end
      when 'test_cases', 'test_case', 'tc'
        case(attribute)
          when 'high_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'hlr',
                                             'tc',
                                             'test_case_id',
                                             'high_level_requirement_id')
          when 'low_level_requirement_associations'
            result = self.insert_association(id,
                                             association_id,
                                             'llr',
                                             'tc',
                                             'test_case_id',
                                             'low_level_requirement_id')
        end
      when 'test_procedures', 'test_procedure', 'tp'
        result     = self.insert_association(id,
                                             association_id,
                                             'tcs',
                                             'tp',
                                             'test_procedure_id',
                                             'test_case_id')
    end
  end

  def self.associate(object, attribute, association_ids = object[attribute])
    result = false

    return result unless object.present? && attribute.present?

    self.clear_association(object, attribute)

    if association_ids.kind_of?(String)
      association_ids = association_ids.split(',')
    end

    association_ids.each do |association_id|
      next unless association_id.present?

      self.set_association(object.id, association_id, object.class.name.tableize,
                           attribute)
    end if association_ids.present?

    result = true

    return result
  end

  def self.build_associations(object)
    result     = false

    return result unless object.present?

    object = object.class.find(object.id) if object.id.present?

    case object.class.name.tableize
      when 'high_level_requirements'
        result = self.associate(object,
                                'system_requirement_associations')
        result = self.associate(object,
                                'high_level_requirement_associations') if result

      when 'low_level_requirements'
        result = self.associate(object,
                                'high_level_requirement_associations')

      when 'model_files'
        result = self.associate(object,
                                'system_requirement_associations')
        result = self.associate(object,
                                'high_level_requirement_associations') if result
        result = self.associate(object,
                                'low_level_requirement_associations')  if result
        result = self.associate(object,
                                'test_case_associations')              if result

      when 'module_descriptions'
        result = self.associate(object,
                                'high_level_requirement_associations')
        result = self.associate(object,
                                'low_level_requirement_associations')  if result

      when 'source_codes'
        result = self.associate(object,
                                'high_level_requirement_associations')
        result = self.associate(object,
                                'low_level_requirement_associations')  if result
        result = self.associate(object,
                                'module_description_associations')  if result

      when 'test_cases'
        result = self.associate(object,
                                'high_level_requirement_associations')
        result = self.associate(object,
                                'low_level_requirement_associations')  if result

      when 'test_procedures'
        result = self.associate(object,
                                'test_case_associations',
                                object.test_case_associations)
    end

    return result
  end

  def self.clone_associations(source_object,
                              destination_object,
                              session_id = nil)
    result                            = false

    return result unless source_object.present? && destination_object.present?
    return result unless destination_object.kind_of?(source_object.class)

    table_name                        = source_object.class.name.tableize
    attributes                        = self.set_associations_hash(source_object)

    if attributes.present?
      attributes.each() do |table, associations|
        next if (table_name == 'high_level_requirements') && (table == 'high_level_requirements')

        if table_name == 'high_level_requirements'
          source_parent_id            = source_object.project_id
          destination_parent_id       = destination_object.project_id
          attribute                   = 'system_requirement_associations'
        else
          source_parent_id            = source_object.item_id
          destination_parent_id       = destination_object.item_id
          attribute                   = case(table)
                                            when 'high_level_requirements'
                                              'high_level_requirement_associations'
                                            when 'low_level_requirements'
                                              'low_level_requirement_associations'
                                            when 'test_cases'
                                              'test_case_associations'
                                        end
        end

        next unless source_parent_id.present?      &&
                    destination_parent_id.present? &&
                    attribute.present?             &&
                    associations.present?

        full_ids                      = self.get_associations_as_full_ids(table,
                                                                          source_object.class.name.tableize,
                                                                          source_parent_id,
                                                                          associations)
        destination_object[attribute] = self.set_associations_from_full_ids(table,
                                                                            source_object.class.name.tableize,
                                                                            destination_parent_id,
                                                                            full_ids,
                                                                            true)
      end

      data_change                     = DataChange.save_or_destroy_with_undo_session(destination_object,
                                                                                     'update',
                                                                                     destination_object.id,
                                                                                     table_name,
                                                                                     session_id)

      if  data_change.present?
        session_id                    = data_change.session_id
        result                        = self.build_associations(destination_object)
      else
        result                        = false
      end
    else
      result = true
    end

    return result
  end
end
