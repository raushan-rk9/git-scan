class SpecObject < ApplicationRecord
  @@data_types     = nil
  @@spec_types     = nil
  @@spec_relations = nil

  def self.get_xml_elements(xml_data, xpath_query, *arglist)
    result  = []
    options = {
                :missing_ok => false
              }

    arglist.each {|arg| options = options.merge(arg) if arg.is_a?(Hash) }

    begin
      contents = xml_data.xpath(xpath_query)
    rescue => e
      raise "Error while locating data: #{xpath_query}. Error: #{e.message}"
    end

    raise "Can't locate data: #{xpath_query} in XML data" if (contents.nil? && !options[:missing_ok]) 
    return result unless contents

    result = contents

    result
  end

  def self.get_single_xml_element(xml_data, xpath_query, *arglist)
    result  = nil
    options = {
                :element_type  => :string,
                :missing_ok    => false,
                :unescape_text => true
              }

    arglist.each {|arg| options = options.merge(arg) if arg.is_a?(Hash) }

    begin
      contents = xml_data.at_xpath(xpath_query)
    rescue => e
      raise "Error while locating data: #{xpath_query}. Error: #{e.message}"
    end

    raise "Can't locate data: #{xpath_query} in XML data" if (contents.nil? && !options[:missing_ok]) 
    return result unless contents

    contents = contents.to_s
    contents = $1 if (contents =~ /^<.+>(.*)<.+>$/m)
    contents = CGI::unescapeHTML(contents) if options[:unescape_text]

    case options[:element_type]
      when :integer
        begin
            Integer(contents)

            result = contents.to_i
        rescue => e
            raise "Invalid Integer '#{contents}' in #{xpath_query}. Error: #{e.message}"
        end
      when :float
        begin
            Float(contents)

            result = contents.to_f
        rescue => e
            raise "Invalid float '#{contents}' in #{xpath_query}. Error: #{e.message}"
        end
      when :date
        begin
            result = Date.parse(contents)
        rescue => e
            raise "Invalid Date '#{contents}' in #{xpath_query}. Error: #{e.message}"
            result[:status]         = :error
        end
      when :boolean
        result = (contents.upcase == 'TRUE')
      else
        result = contents
    end

    result
  end


  def self.get_data_types
    @@data_types
  end

  def self.set_data_types(data_types)
    @@data_types = data_types
  end

  def self.get_spec_types
    @@spec_types
  end

  def self.set_spec_types(spec_types)
    @@spec_types = spec_types
  end

  def self.get_spec_relations
    @@spec_relations
  end

  def self.set_spec_relations(spec_relations)
    @@spec_relations  = spec_relations
  end

  def self.get_requirement(spec_object, project_id)
    return nil unless spec_object.present?
    
    spec_object_json = spec_object.to_json
    spec_object_json = JSON.parse(spec_object_json) if spec_object_json
    spec_object_json = spec_object_json.to_h if spec_object_json.kind_of?(Array)

    spec_object.children.each do |element|
      next unless element.kind_of?(Nokogiri::XML::Element)

      if (element.name == 'TYPE')
        element.children.each do |child|
          next unless child.kind_of?(Nokogiri::XML::Element)

          if child.name == 'SPEC-OBJECT-TYPE-REF'

          end
        end
      elsif (element.name == 'VALUES')
        element.children.each do |child|
          next unless child.kind_of?(Nokogiri::XML::Element)
        end
      end
    end

    system_requirement              = SystemRequirement.new
    system_requirement.project_id   = project_id
    system_requirement.full_id      = requirement["IDENTIFIER"]
    system_requirement.description  = requirement["DESC"]
    last_change                     = requirement["LAST-CHANGE"]
    system_requirement.organization = User.current.organization if     User.current.present?
    system_requirement.reqid        = Regexp.last_match(1).to_i if     system_requirement.full_id =~ /^.*(\d+)$/
    system_requirement.description  = requirement["LONG-NAME"]  unless system_requirement.description.present?

    begin
      last_change                   = last_change.to_datetime
    rescue
      last_change                   = nil
    end

    if last_change.present?
      system_requirement.created_at = last_change
      system_requirement.updated_at = last_change
    end

    system_requirement
  end

  def self.get_requirements(document_path, project_id)
    requirements        = []
    reqif               = ReqIf.new

    reqif.parse_document(document_path)

    return specs unless reqif.present?

    self.set_data_types(reqif.data_types)
    self.set_spec_types(reqif.spec_types)
    self.set_spec_relations(reqif.spec_relations_groups)

    reqif.spec_objects.children.each do |spec_object|
      next unless spec_object.present?

      requirement = self.get_requirement(spec_object, project_id)

      next unless requirement.present?

      requirements.push(requirement)
    end

    requirements
  end
end
