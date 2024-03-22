class ReqIf
  attr_reader :input
  attr_reader :header
  attr_reader :reqif_header
  attr_reader :document
  attr_reader :data_types
  attr_reader :spec_types
  attr_reader :spec_objects
  attr_reader :spec_relations
  attr_reader :specifications
  attr_reader :spec_relations_groups
  attr_reader :requirements

  XML_FILE                 = 'pact.xml'
  ROOT_ELEMENT             = 'REQ-IF'
  HEADER_ELEMENT           = 'THE-HEADER'
  REQIF_HEADER_ELEMENT     = 'REQ-IF-HEADER'
  CORE_CONTENT_ELEMENT     = 'CORE-CONTENT'
  REQIF_CONTENT_ELEMENT    = 'REQ-IF-CONTENT'
  DATA_TYPES_ELEMENT       = 'DATATYPES'
  SPEC_TYPES_ELEMENT       = 'SPEC-TYPES'
  SPEC_OBJECTS_ELEMENT     = 'SPEC-OBJECTS'
  SPEC_RELATIONS_ELEMENT   = 'SPEC-RELATIONS'
  SPECIFICATIONS_ELEMENTS  = 'SPECIFICATIONS'
  SPEC_RELATIONS_GROUPS    = 'SPEC-RELATION-GROUPS'
  VALUES_ELEMENTS          = 'VALUES'
  VALUE_ELEMENTS           = 'VALUE'
  DEFINITION_ELEMENTS      = 'DEFINITION'
  START_OBJECTS            = '<!--START OBJECTS-->'
  DEFAULT_ELEMENTS         = [
                                    :projects,
                                    :items,
                                    :system_requirements,
                                    :high_level_requirements,
                                    :low_level_requirements,
                                    :test_cases,
                                    :test_procedures,
                                    :source_codes
                              ]

  def initialize(*args)
    @input                  = nil
    @document               = nil
    @header                 = nil
    @reqif_header_element   = nil
    @data_types             = nil
    @spec_types             = nil
    @spec_objects           = nil
    @spec_relations         = nil
    @specifications         = nil
    @spec_relations_groups  = nil
    @requirements           = nil
    @identifiers            = {}
    @relations              = {}
 
    if args.present?
      if args.length == 1
        parse_document(args[0])
      else
        parse_document(args)
      end
    end

    @specifications
  end

  def parse(document_contents = @document, root_element = ROOT_ELEMENT)
    @reqif = get_xml_elements(document_contents, root_element)

    @reqif
  end

  def parse_file(document_path, root_element = ROOT_ELEMENT)
    document_contents = File.read(document_path)
    @reqif            = parse(document_contents, root_element)
  end

  def parse_document(*args)
    @input                    = nil 
    @header                   = nil
    reqif_content             = nil
    core_content              = nil
    reqif                     = nil
    root_path                 = ROOT_ELEMENT
    header_element            = HEADER_ELEMENT
    reqif_header_element      = REQIF_HEADER_ELEMENT
    header_element            = HEADER_ELEMENT
    reqif_header_element      = REQIF_HEADER_ELEMENT
    core_content_element      = CORE_CONTENT_ELEMENT
    reqif_content_element     = REQIF_CONTENT_ELEMENT
    data_types_element        = DATA_TYPES_ELEMENT
    spec_types_element        = SPEC_TYPES_ELEMENT
    spec_objects_element      = SPEC_OBJECTS_ELEMENT
    spec_relations_element    = SPEC_RELATIONS_ELEMENT
    specifications_elements   = SPECIFICATIONS_ELEMENTS
    spec_relations_groups     = SPEC_RELATIONS_GROUPS
  
    if args.present?
      arg                     = args[0]

      if arg.instance_of?(String)
        @input                = File.open(arg)                    unless @input.present?
        @document             = Nokogiri::XML(@input)             unless @document.present?
      elsif arg.instance_of?(IO)
        @input                = arg                               unless @input.present?
        @document             = Nokogiri::XML(@input)             unless @document.present?
      elsif arg.instance_of?(Nokogiri::XML)
        @document             = arg
      elsif arg.instance_of?(Hash)
        options               = arg
        root_path             = option[:root_path]                if option[:root_path].present?
        header_element        = option[:header_element]           if option[:header_element].present?
        reqif_header_element  = option[:reqif_header_element]     if option[:reqif_header_element].present?
        core_content_element  = option[:core_content_element]     if option[:heder_element].present?
        reqif_content_element = option[:reqif_content_element]    if option[:reqif_content_element].present?

        if options[:filename].present?
          @input              = File.open(options[:filename])     unless @input.present?
          @document           = Nokogiri::XML(options[:filename]) unless @document.present?
        elsif options[:io].present?
          @input              = options[:io]                      unless @input.present?
          @document           = Nokogiri::XML(@input)             unless @document.present?
        elsif options[:text].present?
          @document           = Nokogiri::XML(options[:text])     unless @document.present?
        end
      end
    end

    if @document.present?
      reqif                   = @document.at(root_path)
      @header                 = @document.at(header_element)
      @reqif_header           = @document.at(reqif_header_element)
      core_content            = @document.at(core_content_element)
      reqif_content           = @document.at(reqif_content_element)
      @data_types             = @document.at(data_types_element)
      @spec_types             = @document.at(spec_types_element)
      @spec_objects           = @document.at(spec_objects_element)
      @spec_relations         = @document.at(spec_relations_element)
      @specifications         = @document.at(specifications_elements)
      @spec_relations_groups  = @document.at(spec_relations_groups)
      @requirements           = get_requirements(@spec_objects,
                                                 @spec_types,
                                                 @data_types,
                                                 @spec_relations,
                                                 @spec_relations_groups)
    end
  end

  def export(filename,
             project_id,
             elements = DEFAULT_ELEMENTS)
    result         = setup_export(filename,
                                  project_id,
                                  elements)
    result         = process_objects(elements)        if result
    result         = process_spec_relations(File.join(Rails.root,
                                                      'app',
                                                      'assets',
                                                      'XML',
                                                      'spec_relation.xml'),
                                            elements) if result
    result         = process_specifications(elements)      if result
    result         = finalize_file                         if result

    if @input_file.present?
      @input_file.close  

      @input_file  = nil
    end

    if @output_file.present?
      @output_file.close

      @output_file = nil
    end

    return result
  end

  def get_associations(elements = DEFAULT_ELEMENTS)
    result                            = true
    @missing_links                    = []
    @project_children                 = []
    @item_children                    = []
    @system_requirements_children     = []
    @high_level_requirements_children = []
    @low_level_requirements_children  = []
    @test_cases_children              = []

    @test_procedures.each do |test_procedure|
      if test_procedure.test_case_associations.present?
        test_cases                    = test_procedure.test_case_associations.split(',')

        test_cases.each do |test_case_id|
          test_case                   = nil

          begin
            test_case                 = TestCase.find(test_case_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @test_cases_children.push([
                                       test_case.long_id,
                                       test_procedure.long_id
                                    ]) if test_case.present?
        end
      end
    end if elements.include?(:test_procedures)

    @test_cases.each do |test_case|
      if test_case.derived
        @item_children.push(test_case)
      end

      if test_case.low_level_requirement_associations.present?
        low_level_requirements = test_case.low_level_requirement_associations.split(',')

        low_level_requirements.each do |low_level_requirement_id|
          low_level_requirement       = nil

          begin
            low_level_requirement     = LowLevelRequirement.find(low_level_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @low_level_requirements_children.push([
                                                  low_level_requirement.long_id,
                                                  test_case.long_id
                                                ]) if low_level_requirement.present?
        end
      end

      if test_case.high_level_requirement_associations.present?
        high_level_requirements       = test_case.high_level_requirement_associations.split(',')

        high_level_requirements.each do |high_level_requirement_id|
          high_level_requirement      = nil

          begin
            high_level_requirement    = HighLevelRequirement.find(high_level_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @high_level_requirements_children.push([
                                                    high_level_requirement.long_id,
                                                    test_case.long_id
                                                 ]) if high_level_requirement.present?
        end
      end
    end if elements.include?(:test_cases)

    @source_codes.each do |source_code|
      if source_code.derived
        @item_children.push(source_code.long_id)
      end

      if source_code.low_level_requirement_associations.present?
        low_level_requirements        = source_code.low_level_requirement_associations.split(',')

        low_level_requirements.each do |low_level_requirement_id|
          low_level_requirement       = nil

          begin
            low_level_requirement     = LowLevelRequirement.find(low_level_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @low_level_requirements_children.push([
                                                   low_level_requirement.long_id,
                                                   source_code.long_id
                                                ]) if low_level_requirement.present?
        end
      end

      if source_code.high_level_requirement_associations.present?
        high_level_requirements       = source_code.high_level_requirement_associations.split(',')

        high_level_requirements.each do |high_level_requirement_id|
          high_level_requirement      = nil

          begin
            high_level_requirement    = HighLevelRequirement.find(high_level_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @high_level_requirements_children.push([
                                                   high_level_requirement.long_id,
                                                   source_code.long_id
                                                 ]) if high_level_requirement.present?
        end
      end
    end if elements.include?(:source_codes)

    @low_level_requirements.each do |low_level_requirement|
      if low_level_requirement.derived
        @item_children.push(low_level_requirement)
      end

      if low_level_requirement.high_level_requirement_associations.present?
        high_level_requirements       = low_level_requirement.high_level_requirement_associations.split(',')

        high_level_requirements.each do |high_level_requirement_id|
          high_level_requirement      = nil

          begin
            high_level_requirement    = HighLevelRequirement.find(high_level_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @high_level_requirements_children.push([
                                                   high_level_requirement.long_id,
                                                   low_level_requirement.long_id
                                                 ]) if high_level_requirement.present?
        end
      end
    end if elements.include?(:low_level_requirements)

    @high_level_requirements.each do |high_level_requirement|
      @item_children.push(high_level_requirement.long_id)

      if high_level_requirement.system_requirement_associations.present?
        system_requirements           = high_level_requirement.system_requirement_associations.split(',')

        system_requirements.each do |system_requirement_id|
          system_requirement          = nil

          begin
            system_requirement        = SystemRequirement.find(system_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @system_requirements_children.push([
                                                system_requirement.full_id,
                                                high_level_requirement.long_id
                                              ]) if system_requirement.present?
        end
      end

      if high_level_requirement.high_level_requirement_associations.present?
        hlrs                          = high_level_requirement.high_level_requirement_associations.split(',')

        hlrs.each do |high_level_requirement_id|
          hlr                         = nil

          begin
            hlr                       = HighLevelRequirement.find(high_level_requirement_id)
          rescue => e
            result                    = false

            @missing_links.push(e.message)
          end

          @high_level_requirements_children.push([
                                                   high_level_requirement.long_id,
                                                   hlr.long_id
                                                 ]) if hlr.present?
        end
      end
    end if elements.include?(:high_level_requirements)

    @items.each do |item|
      @project_children.push(item)
    end if elements.include?(:items)
  end

  def get_value(field, type_wanted = :string)
    result       = case type_wanted
                     when :string, :identifier
                       ''
                     when :integer
                       '0'
                     when :real
                       '0.0'
                     when :date
                       DateTime.now.strftime('%Y-%m-%dT%H:%M:%S')
                     when :boolean
                       'false'
                     else
                       ''
                   end

    return result unless field.present?

    case type_wanted
      when :string
        begin
          result = ERB::Util.html_escape(field).to_s
        rescue
          result = ""
        end

        result.gsub!("\n", '\n')
        result.gsub!("\r", '\r')

      when :identifier
        result = field.to_s

        result.gsub!(':', '-')
        result.gsub!('<', '')
        result.gsub!('>', '')

      when :integer
        begin
          result = field.to_s
        rescue
          result = "0"
        end

      when :real
        begin
          result = Float(field)
        rescue
          result = "0.0"
        end

      when :date
        begin
          result = field.strftime('%Y-%m-%dT%H:%M:%S')
        rescue
          result = ""
        end

      when :boolean
        result = field ? 'true' : 'false'
    end

    result       = '' if result == 'nil'

    return result
  end

private

  def get_children(parent, search)
    result = if parent.present?
               remove_text_elements(parent.search(search))
             else
               []
             end

    result
  end

  def get_requirements(spec_objects, spec_types,
                       data_types, spec_relations,
                       spec_relations_groups)
    results     = []

    return results unless spec_objects.present?

    spec_objects.children.each do |spec_object|
      values = get_xml_elements(spec_object, VALUES_ELEMENTS)

      values.each do |value|

        value.children.each do |child|
          next unless child.is_a?(Nokogiri::XML::Element)

          definitions = get_xml_elements(child, DEFINITION_ELEMENTS)
          
          definitions.each do |definition|
            next unless definition.is_a?(Nokogiri::XML::Element)

            definition.children.each do |field|
            next unless field.is_a?(Nokogiri::XML::Element)
            end
          end
        end if values.children.present?
      end if values.present?
    end

    results
  end

  def get_xml_elements(xml_data, search, *arglist)
    result     = []
    options    = {
                   :missing_ok => false
                 }

    arglist.each {|arg| options = options.merge(arg) if arg.is_a?(Hash) }

    begin
      contents = xml_data.search(search)
    rescue => e
      raise "Error while locating data: #{search}. Error: #{e.message}"
    end

    raise "Can't locate data: #{search} in XML data" if (contents.nil? && !options[:missing_ok]) 
    return result unless contents

    result     = contents

    result
  end

  def get_single_xml_element(xml_data, search, *arglist)
    result         = nil
    options        = {
                       :element_type  => :string,
                       :missing_ok    => false,
                       :unescape_text => true
                     }

    arglist.each {|arg| options = options.merge(arg) if arg.is_a?(Hash) }

    begin
      contents     = xml_data.search(search)
    rescue => e
      raise "Error while locating data: #{search}. Error: #{e.message}"
    end

    raise "Can't locate data: #{search} in XML data" if (contents.nil? && !options[:missing_ok]) 
    return result unless contents

    contents       = contents.to_s
    contents       = $1 if (contents =~ /^<.+>(.*)<.+>$/m)
    contents       = CGI::unescapeHTML(contents) if options[:unescape_text]

    case options[:element_type]
      when :integer
        begin
            Integer(contents)

            result = contents.to_i
        rescue => e
            raise "Invalid Integer '#{contents}' in #{search}. Error: #{e.message}"
        end
      when :float
        begin
            Float(contents)

            result = contents.to_f
        rescue => e
            raise "Invalid float '#{contents}' in #{search}. Error: #{e.message}"
        end
      when :date
        begin
            result = Date.parse(contents)
        rescue => e
            raise "Invalid Date '#{contents}' in #{search}. Error: #{e.message}"
            result[:status]         = :error
        end
      when :boolean
        result     = (contents.upcase == 'TRUE')
      else
        result     = contents
    end

    result
  end

  def get_item_attributes(item)
    result                    = nil

    if item.is_a?(Nokogiri::XML::Element)
      item.children do |subitem|
        attributes            = get_item_attributes(subitem)

        if attributes.is_a?(Array)
          result             += attributes
        elsif attributes.is_a?(Hash)
          attributes.each do |key, value|
            result.push([key, value])
          end
        else
          result.push(attributes)
        end
      end
    elsif item.is_a?(Array)
      result                  = []

      item.each do |subitem|
        if subitem.is_a?(Nokogiri::XML::Attr)
          result.push([subitem.name, subitem.value])
        else
          attributes          = get_item_attributes(subitem)

          if attributes.is_a?(Array)
            result           += attributes
          elsif attributes.is_a?(Hash)
            attributes.each do |key, value|
              result.push([key, value])
            end
          else
            result.push(attributes)
          end
        end
      end
    elsif item.is_a?(Hash)
      result                  = {}

      item.each do |key, value|
        if value.is_a?(Nokogiri::XML::Attr)
          result[value.name]  = value.value
        else
          attributes          = get_item_attributes(value)

          if attributes.is_a?(Hash)
            result.merge(attributes)
          else
            result[key]       = attributes
          end
        end
      end
    elsif item.is_a?(Nokogiri::XML::Attr)
      result[item.name] = item.value
    else
      result = item
    end

    return result
  end

  def remove_text_elements(item)
    item.children.each { |child| child.remove if child.instance_of?(Nokogiri::XML::Text) } if item.present?

    item
  end

  def setup_export(filename,
                   project_id,
                   elements = DEFAULT_ELEMENTS)
    result                      = true
    @filename                   = filename
    @project                    = nil
    @system_requirements        = []
    @items                      = []
    @high_level_requirements    = []
    @low_level_requirements     = []
    @test_cases                 = []
    @test_procedures            = []
    @source_codes               = []

    return false unless project_id.present?

    begin
      @project                  = Project.find(project_id)
      @input_file               = File.open(File.join(Rails.root, 'app', 'assets', 'XML', XML_FILE))
      @output_file              = File.open(@filename, 'w')
    rescue
      return false
    end

    @system_requirements        = SystemRequirement.where(project_id:   project_id,
                                                          archive_id:   nil,
                                                          organization: User.current.organization).order(:reqid) if elements.include?(:system_requirements)
    @items                      = Item.where(project_id: project_id)

    @items.each do |item|
      hlrs                      = HighLevelRequirement.where(item_id: item.id,
                                                             archive_id:   nil,
                                                             organization: User.current.organization).order(:reqid)    if elements.include?(:high_level_requirements)
      llrs                      = LowLevelRequirement.where(item_id: item.id,
                                                            archive_id:   nil,
                                                            organization: User.current.organization).order(:reqid)     if elements.include?(:low_level_requirements)
      tcs                       = TestCase.where(item_id: item.id,
                                                 archive_id:   nil,
                                                 organization: User.current.organization).order(:caseid)               if elements.include?(:test_cases)
      tps                       = TestProcedure.where(item_id: item.id,
                                                      archive_id:   nil,
                                                      organization: User.current.organization).order(:procedure_id)    if elements.include?(:test_procedures)
      scs                       = SourceCode.where(item_id: item.id,
                                                   archive_id:   nil,
                                                   organization: User.current.organization).order(:codeid)             if elements.include?(:source_codes)
      @high_level_requirements += hlrs.to_a if hlrs.present?
      @low_level_requirements  += llrs.to_a if llrs.present?
      @test_cases              += tcs.to_a  if tcs.present?
      @test_procedures         += tps.to_a  if tps.present?
      @source_codes            += scs.to_a  if scs.present?
    end if @items.present?

    while (line = @input_file.gets)
      line.chomp!
      line.gsub!('DATETIME_NOW', get_value(DateTime.now, :date))
      line.gsub!('HEADER_IDENTIFIER', get_value(get_identifier(@project.identifier)))
      line.gsub!('PROJECT.NAME', get_value(@project.name)) if @project.present?

      break if line.chomp == START_OBJECTS

      @output_file.puts(line)
    end

    return result
  end

  def process_objects(elements = DEFAULT_ELEMENTS)
    result   = true

    @output_file.puts('      <SPEC-OBJECTS>')

    result   = process_projects                      if elements.include?(:projects)
    result   = process_items                         if elements.include?(:items)
    result   = process_system_requirements           if elements.include?(:system_requirements)
    result   = process_high_level_requirements       if result &&
                                                        elements.include?(:high_level_requirements)
    result   = process_low_level_requirements        if result &&
                                                        elements.include?(:low_level_requirements)
    result   = process_test_cases                    if result &&
                                                        elements.include?(:test_cases)
    result   = process_test_procedures               if result &&
                                                        elements.include?(:test_procedures)
    result   = process_source_codes                  if result &&
                                                        elements.include?(:source_codes)

    @output_file.puts('      </SPEC-OBJECTS>')

    return result
  end

  def process_projects(project_template_filename = nil)
    result                    = true
    project_template_filename = File.join(Rails.root,
                                          'app',
                                          'assets',
                                          'XML',
                                          'project.xml') unless project_template_filename.present?
    project_template_lines    = File.readlines(project_template_filename).each {|line| line.chomp!}

    project_template_lines.each do |template_line|
      line                    = template_line.dup

      line.chomp!
      line.gsub!('DATETIME_NOW',           get_value(DateTime.now, :date))
      line.gsub!("PROJECT_IDENTIFIER",     get_value(@project.long_id, :identifier))
      line.gsub!("PROJECT_NAME",           get_value(@project.name))
      line.gsub!("PROJECT_DESCRIPTION",    get_value(@project.description))
      line.gsub!("PROJECT_SYSREQ_COUNT",   get_value(@project.sysreq_count, :integer))
      line.gsub!("PROJECT_PR_COUNT",       get_value(@project.pr_count, :integer))
      line.gsub!("PROJECT_MANAGERS",       get_value(@project.project_managers.join( ',')))
      line.gsub!("PROJECT_CONFIGURATION_MANAGERS",
                 get_value(@project.configuration_managers.join( ',')))
      line.gsub!("PROJECT_QUALITY_ASSURANCE",
                 get_value(@project.quality_assurance.join( ',')))
      line.gsub!("PROJECT_TEAM_MEMBERS",   get_value(@project.team_members.join( ',')))
      line.gsub!("PROJECT_AIRWORTHINESS_REPS",
                 get_value(@project.airworthiness_reps.join( ',')))
      line.gsub!("PROJECT_SYSTEM_REQUIREMENTS_PREFIX",
                 get_value(@project.system_requirements_prefix))
      line.gsub!("PROJECT_HIGH_LEVEL_REQUIREMENTS_PREFIX",
                 get_value(@project.high_level_requirements_prefix))
      line.gsub!("PROJECT_PROJECT_LOW_LEVEL_REQUIREMENTS_PREFIX",
                 get_value(@project.low_level_requirements_prefix))
      line.gsub!("PROJECT_SOURCE_CODE_PREFIX",
                 get_value(@project.source_code_prefix))
      line.gsub!("PROJECT_TEST_CASE_PREFIX",
                 get_value(@project.test_case_prefix))
      line.gsub!("PROJECT_TEST_PROCEDURE_PREFIX",
                 get_value(@project.test_procedure_prefix))
      line.gsub!("PROJECT_MODEL_FILE_PREFIX",
                 get_value(@project.model_file_prefix))
      line.gsub!('PROJECT_ID',             get_value(@project.id, :integer))
      @output_file.puts(line)
    end

    return(result)
  end

  def process_items(item_template_filename = nil)
    result                 = true
    item_template_filename = File.join(Rails.root,
                                       'app',
                                       'assets',
                                       'XML',
                                       'item.xml') unless item_template_filename.present?
    item_template_lines    = File.readlines(item_template_filename).each {|line| line.chomp!}

    @items.each do |item|
      item_template_lines.each do |template_line|
        line                    = template_line.dup

        line.chomp!
        line.gsub!('DATETIME_NOW',         get_value(DateTime.now, :date))
        line.gsub!('ITEM_NAME',            get_value(item.name))
        line.gsub!("ITEM_ITEMTYPE",        get_value(item.itemtype, :integer))
        line.gsub!("ITEM_ITEM_IDENTIFIER", get_value(item.long_id, :identifier))
        line.gsub!("ITEM_IDENTIFIER",      get_value(item.identifier))
        line.gsub!("ITEM_LEVEL",           get_value(item.level))
        line.gsub!("ITEM_HLR_COUNT",       get_value(item.hlr_count, :integer))
        line.gsub!("ITEM_LLR_COUNT",       get_value(item.llr_count, :integer))
        line.gsub!("ITEM_REVIEW_COUNT",    get_value(item.review_count, :integer))
        line.gsub!("ITEM_TC_COUNT",        get_value(item.tc_count, :integer))
        line.gsub!("ITEM_TP_COUNT",        get_value(item.tp_count, :integer))
        line.gsub!("ITEM_SC_COUNT",        get_value(item.sc_count, :integer))
        line.gsub!("ITEM_HIGH_LEVEL_REQUIREMENTS_PREFIX",
                   get_value(item.high_level_requirements_prefix))
        line.gsub!("ITEM_ITEM_LOW_LEVEL_REQUIREMENTS_PREFIX",
                   get_value(item.low_level_requirements_prefix))
        line.gsub!("ITEM_SOURCE_CODE_PREFIX",
                   get_value(item.source_code_prefix))
        line.gsub!("ITEM_TEST_CASE_PREFIX",
                   get_value(item.test_case_prefix))
        line.gsub!("ITEM_TEST_PROCEDURE_PREFIX",
                   get_value(item.test_procedure_prefix))
        line.gsub!("ITEM_MODEL_FILE_PREFIX",
                   get_value(item.model_file_prefix))
        line.gsub!('ITEM_ID',              get_value(item.id, :integer))
        @output_file.puts(line)
      end
    end

    return(result)
  end

  def process_system_requirements(system_requirement_template_filename = nil)
    system_requirement_template_filename = File.join(Rails.root,
                                                     'app',
                                                     'assets',
                                                     'XML',
                                                     'system_requirement.xml') unless system_requirement_template_filename.present?
    result                               = true
    system_requirement_template          = File.readlines(system_requirement_template_filename).each {|line| line.chomp!}

    @system_requirements.each do |system_requirement|
      system_requirement_template.each do |template_line|
        line                             = template_line.dup

        line.chomp!
        line.gsub!('SYSTEM_REQUIREMENT_IDENTIFIER', get_value(system_requirement.long_id, :identifier))
        line.gsub!('DATETIME_NOW',                  get_value(DateTime.now, :date))
        line.gsub!('SYSTEM_REQUIREMENT_ID',
                   get_value("SYSTEM_REQUIREMENT_#{system_requirement.id.to_s}"))
        line.gsub!('SYSTEM_REQUIREMENT_REQ_ID',
                   get_value(system_requirement.reqid, :integer))
        line.gsub!('SYSTEM_REQUIREMENT_FULL_ID',
                   get_value(system_requirement.full_id))
        line.gsub!('SYSTEM_REQUIREMENT_DESCRIPTION',
                   get_value(system_requirement.description))
        line.gsub!('SYSTEM_REQUIREMENT_SOURCE',
                   get_value(system_requirement.source))
        line.gsub!('SYSTEM_REQUIREMENT_SAFETY',
                   get_value(system_requirement.safety, :boolean))
        line.gsub!('SYSTEM_REQUIREMENT_IMPLEMENTATION',
                   get_value(system_requirement.implementation))
        line.gsub!('SYSTEM_REQUIREMENT_VERSION',
                   get_value(system_requirement.version, :integer))
        line.gsub!('SYSTEM_REQUIREMENT_CATEGORY',
                   get_value(system_requirement.category))

        if line.index('SYSTEM_VERIFICATION_METHOD')
          xml = system_requirement.verification_method.to_xml

          line.gsub!('SYSTEM_VERIFICATION_METHOD', '')
        end

        line.gsub!('SYSTEM_REQUIREMENT_DERIVED_JUSTIFICATION',
                   get_value(system_requirement.derived_justification))
        line.gsub!('SYSTEM_REQUIREMENT_DERIVED',
                   get_value(system_requirement, :boolean))
        line.gsub!('SYSTEM_REQUIREMENT_SOFT_DELETE',
                   get_value(system_requirement.soft_delete, :boolean))
        @output_file.puts(line)
      end
    end

    return result
  end

  def process_high_level_requirements
    high_level_requirement_template_filename = File.join(Rails.root,
                                                         'app',
                                                         'assets',
                                                         'XML',
                                                         'high_level_requirement.xml') unless high_level_requirement_template_filename.present?
    result                                   = true
    high_level_requirement_template          = File.readlines(high_level_requirement_template_filename).each {|line| line.chomp!}

    @high_level_requirements.each do |high_level_requirement|
      high_level_requirement_template.each do |template_line|
        line                                 = template_line.dup

        line.chomp!
        line.gsub!('HIGH_LEVEL_REQUIREMENT_IDENTIFIER', get_value(high_level_requirement.long_id, :identifier))
        line.gsub!('DATETIME_NOW',                      get_value(DateTime.now, :date))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_ID',
                   get_value("HIGH_LEVEL_REQUIREMENT_#{high_level_requirement.id.to_s}"))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_REQ_ID',
                   get_value(high_level_requirement.reqid, :integer))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_FULL_ID',
                   get_value(high_level_requirement.long_id, :identifier))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_DESCRIPTION',
                   get_value(high_level_requirement.description))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_CATEGORY',
                   get_value(high_level_requirement.category))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_SAFETY',
                   get_value(high_level_requirement.safety, :boolean))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_ROBUSTNESS',
                   get_value(high_level_requirement.robustness, :boolean))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_DERIVED_JUSTIFICATION',
                   get_value(high_level_requirement.derived_justification))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_DERIVED',
                   get_value(high_level_requirement.derived, :boolean))
        line.gsub!('HIGH_LEVEL_TEST_METHOD',
                   get_value(high_level_requirement.testmethod))
        line.gsub!('HIGH_LEVEL_REQUIREMENT_VERSION',
                   get_value(high_level_requirement.version, :integer))

        if line.index('HIGH_LEVEL_VERIFICATION_METHOD')
          xml = high_level_requirement.verification_method.to_xml

          line.gsub!('HIGH_LEVEL_VERIFICATION_METHOD', '')
        end

        line.gsub!('HIGH_LEVEL_REQUIREMENT_SOFT_DELETE',
                   get_value(high_level_requirement.soft_delete, :boolean))
        @output_file.puts(line)
      end
    end

    return result
  end

  def process_low_level_requirements
    low_level_requirement_template_filename = File.join(Rails.root,
                                                     'app',
                                                     'assets',
                                                     'XML',
                                                     'low_level_requirement.xml') unless low_level_requirement_template_filename.present?
    result                                   = true
    low_level_requirement_template          = File.readlines(low_level_requirement_template_filename).each {|line| line.chomp!}

    @low_level_requirements.each do |low_level_requirement|
      low_level_requirement_template.each do |template_line|
        line                                 = template_line.dup

        line.chomp!
        line.gsub!('LOW_LEVEL_REQUIREMENT_IDENTIFIER', get_value(low_level_requirement.long_id, :identifier))
        line.gsub!('DATETIME_NOW',                     get_value(DateTime.now, :date))
        line.gsub!('LOW_LEVEL_REQUIREMENT_ID',
                   get_value("LOW_LEVEL_REQUIREMENT_#{low_level_requirement.id.to_s}"))
        line.gsub!('LOW_LEVEL_REQUIREMENT_REQ_ID',
                   get_value(low_level_requirement.reqid, :integer))
        line.gsub!('LOW_LEVEL_REQUIREMENT_FULL_ID',
                   get_value(low_level_requirement.long_id, :identifier))
        line.gsub!('LOW_LEVEL_REQUIREMENT_DESCRIPTION',
                   get_value(low_level_requirement.description))
        line.gsub!('LOW_LEVEL_REQUIREMENT_CATEGORY',
                   get_value(low_level_requirement.category))
        line.gsub!('LOW_LEVEL_REQUIREMENT_SAFETY',
                   get_value(low_level_requirement.safety, :boolean))
        line.gsub!('LOW_LEVEL_REQUIREMENT_DERIVED_JUSTIFICATION',
                   get_value(low_level_requirement.derived_justification))
        line.gsub!('LOW_LEVEL_REQUIREMENT_DERIVED',
                   get_value(low_level_requirement.derived, :boolean))
        line.gsub!('LOW_LEVEL_REQUIREMENT_VERSION',
                   get_value(low_level_requirement.version, :integer))

        if line.index('LOW_LEVEL_VERIFICATION_METHOD')
          xml = low_level_requirement.verification_method.to_xml

          line.gsub!('LOW_LEVEL_VERIFICATION_METHOD', '')
        end

        line.gsub!('LOW_LEVEL_REQUIREMENT_SOFT_DELETE',
                   get_value(low_level_requirement.soft_delete, :boolean))
        @output_file.puts(line)
      end
    end

    return result
  end

  def process_test_cases
    test_case_template_filename = File.join(Rails.root,
                                            'app',
                                            'assets',
                                            'XML',
                                            'test_case.xml') unless test_case_template_filename.present?
    result                                   = true
    test_case_template          = File.readlines(test_case_template_filename).each {|line| line.chomp!}

    @test_cases.each do |test_case|
      test_case_template.each do |template_line|
        line                                 = template_line.dup

        line.chomp!
        line.gsub!('TEST_CASE_IDENTIFIER', get_value(test_case.long_id, :identifier))
        line.gsub!('DATETIME_NOW',         get_value(DateTime.now, :date))
        line.gsub!('TEST_CASE_ID',
                   get_value("TEST_CASE_#{test_case.id.to_s}"))
        line.gsub!('TEST_CASE_CASEID',
                   get_value(test_case.caseid, :integer))
        line.gsub!('TEST_CASE_FULL_ID',
                   get_value(test_case.long_id, :identifier))
        line.gsub!('TEST_CASE_DESCRIPTION',
                   get_value(test_case.description))
        line.gsub!('TEST_CASE_PROCEDURE',
                   get_value(test_case.procedure))
        line.gsub!('TEST_CASE_CATEGORY',
                   get_value(test_case.category))
        line.gsub!('TEST_CASE_ROBUSTNESS',
                   get_value(test_case.robustness, :boolean))
        line.gsub!('TEST_CASE_TESTMETHOD',
                   get_value(test_case.testmethod))
        line.gsub!('TEST_CASE_DERIVED_JUSTIFICATION',
                   get_value(test_case.derived_justification))
        line.gsub!('TEST_CASE_DERIVED',
                   get_value(test_case.derived, :boolean))
        line.gsub!('TEST_TEST_TESTMETHOD',
                   get_value(test_case.testmethod))
        line.gsub!('TEST_CASE_VERSION',
                   get_value(test_case.version, :integer))
        line.gsub!('TEST_CASE_SOFT_DELETE',
                   get_value(test_case.soft_delete, :boolean))
        @output_file.puts(line)
      end
    end

    return result
  end

  def process_test_procedures
    test_procedure_template_filename = File.join(Rails.root,
                                                 'app',
                                                 'assets',
                                                 'XML',
                                                 'test_procedure.xml') unless test_procedure_template_filename.present?
    result                           = true
    test_procedure_template          = File.readlines(test_procedure_template_filename).each {|line| line.chomp!}

    @test_procedures.each do |test_procedure|
      file          = test_procedure.upload_file
      file_path     = test_procedure.file_path
      file_contents = ''

      if (file_path.present? && File.exist?(file_path)) ||
         (file.present?      && file.attached?)

        File.open(file_path, 'rb') do |input_file|
          file_contents = Base64.encode64(input_file.read)
        end
      end

      test_procedure_template.each do |template_line|
        line                                 = template_line.dup

        line.chomp!
        line.gsub!('TEST_PROCEDURE_IDENTIFIER', get_value(test_procedure.long_id, :identifier))
        line.gsub!('DATETIME_NOW',              get_value(DateTime.now, :date))
        line.gsub!('TEST_PROCEDURE_ID',
                   get_value("TEST_PROCEDURE_#{test_procedure.id.to_s}"))
        line.gsub!('TEST_PROCEDURE_PROCEDURE_ID',
                   get_value(test_procedure.procedure_id, :integer))
        line.gsub!('TEST_PROCEDURE_FULL_ID',
                   get_value(test_procedure.full_id))
        line.gsub!('TEST_PROCEDURE_FILE_NAME',
                   get_value(test_procedure.description))
        line.gsub!('TEST_PROCEDURE_VERSION',
                   get_value(test_procedure.version, :integer))
        line.gsub!('TEST_PROCEDURE_URL_TYPE',
                   get_value(test_procedure.url_type))
        line.gsub!('TEST_PROCEDURE_URL_DESCRIPTION',
                   get_value(test_procedure.url_description))
        line.gsub!('TEST_PROCEDURE_URL_LINK',
                   get_value(test_procedure.url_link))
        line.gsub!('TEST_PROCEDURE_DESCRIPTION',
                   get_value(test_procedure.description))
        line.gsub!('TEST_PROCEDURE_SOFT_DELETE',
                   get_value(test_procedure.soft_delete, :boolean))
        line.gsub!('TEST_PROCEDURE_FILE_PATH',
                   get_value(test_procedure.description))
        line.gsub!('TEST_PROCEDURE_CONTENT_TYPE',
                   get_value(test_procedure.content_type))
        line.gsub!('TEST_PROCEDURE_FILE_TYPE',
                   get_value(test_procedure.file_type))
        line.gsub!('TEST_PROCEDURE_REVISION_DATE',
                   get_value(test_procedure.revision_date, :date))
        line.gsub!('TEST_PROCEDURE_UPLOAD_DATE',
                   get_value(test_procedure.upload_date, :date))
        line.gsub!('TEST_PROCEDURE_REVISION',
                   get_value(test_procedure.revision))
        line.gsub!('TEST_PROCEDURE_FILE_CONTENTS',
                   get_value(file_contents))
        @output_file.puts(line)
      end
    end

    return result
  end

  def process_source_codes
    source_code_template_filename = File.join(Rails.root,
                                              'app',
                                              'assets',
                                              'XML',
                                              'source_code.xml') unless source_code_template_filename.present?
    result                                   = true
    source_code_template          = File.readlines(source_code_template_filename).each {|line| line.chomp!}

    @source_codes.each do |source_code|
      file          = source_code.upload_file
      file_path     = source_code.file_path
      file_contents = ''

      if (file_path.present? && File.exist?(file_path)) ||
         (file.present?      && file.attached?)

        File.open(file_path, 'rb') do |input_file|
          file_contents = Base64.encode64(input_file.read)
        end
      end

      source_code_template.each do |template_line|
        line                                 = template_line.dup

        line.chomp!
        line.gsub!('SOURCE_CODE_IDENTIFIER', get_value(source_code.long_id, :identifier))
        line.gsub!('DATETIME_NOW',           get_value(DateTime.now, :date))
        line.gsub!('SOURCE_CODE_ID',
                   get_value("SOURCE_CODE_#{source_code.id.to_s}"))
        line.gsub!('SOURCE_CODE_CODEID',
                   get_value(source_code.codeid, :integer))
        line.gsub!('SOURCE_CODE_FULL_ID',
                   get_value(source_code.full_id))
        line.gsub!('SOURCE_CODE_FILE_NAME',
                   get_value(source_code.file_name))
        line.gsub!('SOURCE_CODE_MODULE',
                   get_value(source_code.module))
        line.gsub!('SOURCE_CODE_FUNCTION',
                   get_value(source_code.function))
        line.gsub!('SOURCE_CODE_DERIVED_JUSTIFICATION',
                   get_value(source_code.derived_justification))
        line.gsub!('SOURCE_CODE_DERIVED',
                   get_value(source_code, :boolean))
        line.gsub!('SOURCE_CODE_VERSION',
                   get_value(source_code.version, :integer))
        line.gsub!('SOURCE_CODE_URL_TYPE',
                  get_value(source_code.url_type))
        line.gsub!('SOURCE_CODE_URL_DESCRIPTION',
                   get_value(source_code.url_description))
        line.gsub!('SOURCE_CODE_URL_LINK',
                   get_value(source_code.url_link))
        line.gsub!('SOURCE_CODE_DESCRIPTION',
                   get_value(source_code.description))
        line.gsub!('SOURCE_CODE_SOFT_DELETE',
                   get_value(source_code.soft_delete, :boolean))
        line.gsub!('SOURCE_CODE_FILE_PATH',
                   get_value(source_code.file_path))
        line.gsub!('SOURCE_CODE_CONTENT_TYPE',
                   get_value(source_code.content_type))
        line.gsub!('SOURCE_CODE_FILE_TYPE',
                   get_value(source_code.file_type))
        line.gsub!('SOURCE_CODE_REVISION_DATE',
                   get_value(source_code.revision_date, :date))
        line.gsub!('SOURCE_CODE_UPLOAD_DATE',
                   get_value(source_code.upload_date, :date))
        line.gsub!('SOURCE_CODE_REVISION',
                   get_value(source_code.revision))
        line.gsub!('SOURCE_CODE_DRAFT_VERSION',
                   get_value(source_code.draft_version))
        line.gsub!('SOURCE_CODE_EXTERNAL_VERSION',
                   get_value(source_code.external_version))
        line.gsub!('SOURCE_CODE_FILE_CONTENTS',
                   get_value(file_contents))
        @output_file.puts(line)
      end
    end

    return result
  end

  def process_spec_relation(source, target)
    result = true

    @specifications_relation_template.each do |template_line|
      line = template_line.dup

      line.chomp!
      line.gsub!('RELATION_IDENTIFIER', get_value(get_identifier(source, target)))
      line.gsub!('DATETIME_NOW',        get_value(DateTime.now, :date))
      line.gsub!('SOURCE_IDENTIFIER',   get_value(source.long_id, :identifier))
      line.gsub!('TARGET_IDENTIFIER',   get_value(target.long_id, :identifier))
      @output_file.puts(line)
    end

    @relations[pair] = pair

    return result
  end

  def process_spec_relations(specifications_relations_filename,
                             elements = DEFAULT_ELEMENTS)
    result                            = true
    specifications_relations_filename = File.join(Rails.root,
                                                  'app',
                                                  'assets',
                                                  'XML',
                                                  'spec_relation.xml') unless specifications_relations_filename.present?
    @specifications_relation_template = File.readlines(specifications_relations_filename).each {|line| line.chomp!}

    get_associations(elements)
    @output_file.puts('      <SPEC-RELATIONS>')

    process_spec_relation(@project, child) if elements.include?(:project)

    @project.system_requirements do |system_requirement|
      process_spec_relation(@project, system_requirement) if elements.include(:system_requirements)
    end if @project.system_requirements.present?

    @output_file.puts('      </SPEC-RELATIONS>')

    return result
  end

  def process_specifications(elements = DEFAULT_ELEMENTS)
    result                  = true

    @output_file.puts('      <SPECIFICATIONS>')
    @output_file.puts("        <SPECIFICATION IDENTIFIER = \"#{@project.name}\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")
    @output_file.puts('          <VALUES>')
    @output_file.puts("            <ATTRIBUTE-VALUE-STRING THE-VALUE=\"#{@project.long_id}\">")
    @output_file.puts('               <DEFINITION>')
    @output_file.puts('                  <ATTRIBUTE-DEFINITION-STRING-REF>SPECIFICATION-DESCRIPTION</ATTRIBUTE-DEFINITION-STRING-REF>')
    @output_file.puts('               </DEFINITION>')
    @output_file.puts('            </ATTRIBUTE-VALUE-STRING>')
    @output_file.puts('          </VALUES>')
    @output_file.puts('          <TYPE>')
    @output_file.puts('            <SPECIFICATION-TYPE-REF>SPECIFICATION-TYPE</SPECIFICATION-TYPE-REF>')
    @output_file.puts('          </TYPE>')
    @output_file.puts('          <CHILDREN>')
    @output_file.puts("            <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(@project.long_id, :identifier) + '_'}\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")
    @output_file.puts('              <OBJECT>')
    @output_file.puts("                <SPEC-OBJECT-REF>#{get_value(@project.long_id, :identifier)}</SPEC-OBJECT-REF>")
    @output_file.puts('              </OBJECT>')

    if @project.system_requirements.present?
      @output_file.puts('              <CHILDREN>')

      @project.system_requirements.each do |system_requirement|
        @output_file.puts("                <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(system_requirement.long_id, :identifier)}_\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")
        @output_file.puts('                  <OBJECT>')
        @output_file.puts("                    <SPEC-OBJECT-REF>#{get_value(system_requirement.long_id, :identifier)}</SPEC-OBJECT-REF>")
        @output_file.puts('                  </OBJECT>')

        if system_requirement.high_level_requirements.present?
          @output_file.puts('                  <CHILDREN>')

          system_requirement.high_level_requirements.each do |high_level_requirement|
            @output_file.puts("                    <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(high_level_requirement.long_id, :identifier)}_\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")
            @output_file.puts('                      <OBJECT>')
            @output_file.puts("                        <SPEC-OBJECT-REF>#{get_value(high_level_requirement.long_id, :identifier)}</SPEC-OBJECT-REF>")
            @output_file.puts('                      </OBJECT>')

            if high_level_requirement.low_level_requirements.present?
              @output_file.puts('                      <CHILDREN>')

              high_level_requirement.low_level_requirements.each do |low_level_requirement|
                @output_file.puts("                        <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(low_level_requirement.long_id, :identifier)}_\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")
                @output_file.puts('                          <OBJECT>')
                @output_file.puts("                            <SPEC-OBJECT-REF>#{get_value(low_level_requirement.long_id, :identifier)}</SPEC-OBJECT-REF>")
                @output_file.puts('                           </OBJECT>')
                @output_file.puts('                           <CHILDREN>')

                if low_level_requirement.source_codes.present?
                  @output_file.puts("                             <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(low_level_requirement.long_id, :identifier)}_source_codes\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")

                  low_level_requirement.source_codes.each do |source_code|
                    @output_file.puts('                               <OBJECT>')
                    @output_file.puts("                                 <SPEC-OBJECT-REF>#{get_value(source_code.long_id, :identifier)}</SPEC-OBJECT-REF>")
                    @output_file.puts('                               </OBJECT>')
                  end

                  @output_file.puts('                             </SPEC-HIERARCHY>')
                end

                if low_level_requirement.test_cases.present?
                  low_level_requirement.test_cases.each do |test_case|
                    @output_file.puts("                             <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(test_case.long_id, :identifier)}_\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")
                    @output_file.puts('                               <OBJECT>')
                    @output_file.puts("                                 <SPEC-OBJECT-REF>#{get_value(test_case.long_id, :identifier)}</SPEC-OBJECT-REF>")
                    @output_file.puts('                               </OBJECT>')

                    if test_case.test_procedures.present?
                      @output_file.puts('                               <CHILDREN>')
                      @output_file.puts("                                 <SPEC-HIERARCHY IDENTIFIER = \"#{get_value(test_case.long_id, :identifier)}_test_procedures\" LAST-CHANGE = \"#{get_value(DateTime.now, :date)}\">")

                      test_case.test_procedures.each do |test_procedure|
                        @output_file.puts('                                   <OBJECT>')
                        @output_file.puts("                                     <SPEC-OBJECT-REF>#{get_value(test_procedure.long_id, :identifier)}</SPEC-OBJECT-REF>")
                        @output_file.puts('                                   </OBJECT>')
                      end

                      @output_file.puts('                                 </SPEC-HIERARCHY>')
                      @output_file.puts('                               </CHILDREN>')
                    end

                    @output_file.puts('                             </SPEC-HIERARCHY>')
                  end

                  @output_file.puts('                           </CHILDREN>')
                end

                @output_file.puts('                        </SPEC-HIERARCHY>')
              end

              @output_file.puts('                      </CHILDREN>')
            end

            @output_file.puts('                    </SPEC-HIERARCHY>')
          end

          @output_file.puts('                  </CHILDREN>')
        end

        @output_file.puts('                </SPEC-HIERARCHY>')
      end

      @output_file.puts('              </CHILDREN>')
    end

    @output_file.puts('            </SPEC-HIERARCHY>')
    @output_file.puts('          </CHILDREN>')
    @output_file.puts('        </SPECIFICATION>')
    @output_file.puts('      </SPECIFICATIONS>')

    return result
  end

  def finalize_file
    result = true

    while (line = @input_file.gets)
      line.chomp!

      @output_file.puts(line)
    end

    return result
  end

  def get_identifier(object_1, object_2 = nil)
    i                        = 0
    result                   = ''
    unique                   = false
    base_key                 = if (object_1.present? && object_1.respond_to?(:long_id)) &&
                                  (object_2.present? && object_2.respond_to?(:long_id))
                                 get_value(object_1.long_id, :identifier) + ',' +
                                 get_value(object_2.long_id, :identifier)
                               elsif object_1.present? && object_1.respond_to?(:long_id)
                                 get_value(object_1.long_id, :identifier)
                               else
                                 nil
                               end
    key                      = base_key

    return result unless key.present?

    while (!unique)
      sha2                   = Digest::SHA2.hexdigest(key)

      sha2.upcase!

      identifier             = 'A980AE9C-' +
                               sha2[8..11]  + '-' +
                               sha2[12..15] + '-' +
                               sha2[16..19] + '-' +
                               sha2[22..33]
      unique                 = !@identifiers[identifier].present?

      unless unique
        i                   += 1
        key                  = "#{base_key}_#{sprintf('%03', i)}"
      end
    end

    @identifiers[identifier] = if object_2.present?
                                 {
                                   "object_1_id"   => object_1.id,
                                   "object_1_type" => object_1.class.name,
                                   "object_2_id"   => object_2.id,
                                   "object_2_type" => object_2.class.name
                                 }
                                else
                                 {
                                   "object_1_id"   => object_1.id,
                                   "object_1_type" => object_1.class.name
                                 }
                                end

    return result
  end
end
