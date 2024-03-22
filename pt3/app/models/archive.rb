class Archive < OrganizationRecord
  has_one       :project,                    dependent: :destroy
  has_many      :system_requirements,        dependent: :destroy
  has_many      :items,                      dependent: :destroy
  has_many      :high_level_requirements,    dependent: :destroy
  has_many      :low_level_requirements,     dependent: :destroy
  has_many      :source_codes,               dependent: :destroy
  has_many      :test_cases,                 dependent: :destroy
  has_many      :test_procedures,            dependent: :destroy
  has_many      :documents,                  dependent: :destroy
  has_many      :document_comments,          dependent: :destroy
  has_many      :document_attachments,       dependent: :destroy
  has_many      :reviews,                    dependent: :destroy
  has_many      :review_attachments,         dependent: :destroy
  has_many      :checklist_items,            dependent: :destroy
  has_many      :action_items,               dependent: :destroy
  has_many      :problem_reports,            dependent: :destroy
  has_many      :problem_report_histories,   dependent: :destroy
  has_many      :problem_report_attachments, dependent: :destroy

  # Define supplements as an array type.
  serialize     :archive_item_ids, Array

  DEFAULT_EXCLUDED_ITEMS = [
                              'id',
                              'project_id',
                              'item_id',
                              'archive_id'
                           ]

  def self.full_id_from_id(id)
    result     = nil

    return result unless id.present?

    archive    = self.find_by(id: id) if id.present?
    result     = archive.full_id      if archive.present?

    return result
  end

  def self.id_from_full_id(id)
    result     = nil

    return result unless id.present?

    archive = if id.kind_of?(Integer)
                self.find_by(id: id)
              elsif id =~ /^\d+\.*\d*$/
                self.find_by(id: id.to_i)
              else
                self.find_by(full_id: id)
              end
    result  = archive.id if archive.present?

    return result
  end

  def self.name_from_id(id)
    result  = ''
    id      = id.to_i              if id.kind_of?(String)
    archive = self.find_by(id: id) if id.present?
    result  = archive.name         if archive.present?

    return result
  end

  def self.parent_project_id_from_archive_id(id)
    result  = nil
    id      = id.to_i              if id.kind_of?(String)
    archive = self.find_by(id: id) if id.present?
    result  = archive.project_id   if archive.present?

    return result
  end

  def self.project_from_archive_id(id)
    result  = nil
    result  = Project.find_by(archive_id: id) if id.present?

    return result
  end

  def self.archived(options = {})
    result        = false
    project_id    = options[:project_id]
    item_id       = options[:item_id]
    object        = options[:object]
    archive_types = if options[:archive_types].present?
                      options[:archive_types]
                    else
                      [ Constants::SYSTEM_REQUIREMENTS_ARCHIVE ]
                    end
    organization  = if options[:organization].present?
                      options[:organization]
                    else
                      User.current.organization
                    end

    return result unless object.present?     ||
                         project_id.present? ||
                         item_id.present?

    if object.present?
      project_id  = object.try(:project_id) unless project_id.present?
      item_id     = object.try(:item_id)    unless item_id.present?
    end

    archive_types.each do |archive_type|
      archives    = if project_id.present? && item_id.present?
                      Archive.where(archive_type: archive_type,
                                    project_id:   project_id,
                                    item_id:      item_id,
                                    organization: organization)
                    elsif project_id.present?
                      Archive.where(archive_type: archive_type,
                                    project_id:   project_id,
                                    organization: organization)
                    elsif item_id.present?
                      Archive.where(archive_type: archive_type,
                                    item_id:      item_id,
                                    organization: organization)
                    end

      if archives.present?
        result  = true

        break
      end
    end if archive_types.present?

    return result
  end

  def self.generate_key(object, project_id = nil, item_id = nil)
    result     = if object.present?
                   project_id = object.try(:project_id) unless project_id.present?
                   item_id    = object.try(:item_id)    unless item_id.present?
                   result     = object.class.name.tableize
                   result    += '_' + project_id.to_s   if     project_id.present?
                   result    += '_' + item_id.to_s      if     item_id.present?
                   result    += '_' + object.id.to_s
                 else
                   ''
                 end

    return result
  end

  def self.copy_attributes(source_object,
                           destination_object,
                           excluded_items = DEFAULT_EXCLUDED_ITEMS)
    return nil unless source_object.present? && destination_object.present?

    source_object.attributes.each do |attribute, index|
      destination_object[attribute] = source_object[attribute] unless excluded_items.include?(attribute)
    end

    return destination_object
  end

  def self.save_object(object, mode = 'create', session_id = nil)
    result          = nil

    if object.present?
      session_id    = @session_id if session_id.nil? && @session_id.present?

      begin
        data_change   = DataChange.save_or_destroy_with_undo_session(object,
                                                                     mode,
                                                                     object.id,
                                                                     object.class.name.tableize,
                                                                     session_id)
      rescue => e
        if object.archive_id.present?
          return object
        else
          return nil
        end
      end

      if data_change.present?
        @session_id = data_change.session_id unless @session_id.present?
        result      = object
      end
    end

    return result
  end

  def self.add_model_file(object, archive_id, project_id, original_item_id,
                          new_item_id, session_id = nil)
    result = nil

    if object.present? && object.model_file_id.present?
      model_file             = ModelFile.find(object.model_file_id)
      new_model_file         = clone_object(model_file, archive_id,
                                            project_id, new_item_id,
                                            session_id)

      if new_model_file.present?
        object.model_file_id = new_model_file.id
        object               = save_object(object, 'update', session_id)
      end

      result = object
    end

    return result
  end

  def self.get_unique_filename(path, base_filename)
    tries      = 0
    index      = 1
    filename   = File.join(path, base_filename)

    while (tries < 100) && File.exist?(filename)
      filename = File.join(path, "#{index}-#{base_filename}")
      index   += 1
      tries   += 1
    end

    return filename.to_s
  end

  def self.get_root_path
    root  = '/var/folders'
    local  = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
    root   = local['root']                         if local.present?

    return File.join(root, 'files', User.current.organization)
  end

  def self.clone_file(source_object, destination_object, session_id = nil)
    return unless source_object.present? && destination_object.present?

    file                             = source_object.try(:file)
    file                             = source_object.try(:upload_file) unless file.present?
    file_path                        = source_object.try(:file_path)

    return unless (file_path.present? && File.exist?(file_path)) ||
                  (file.present?      && file.attached?)

    root_path                        = if source_object.respond_to?(:get_root_path)
                                         source_object.get_root_path
                                       else
                                         get_root_path
                                       end
    path                             = if destination_object.respond_to?(:parent_id)
                                         archived_documents_folder    = Document.get_or_create_folder(Constants::ARCHIVED_DOCUMENTS,
                                                                                                      destination_object.project_id,
                                                                                                      destination_object.item_id,
                                                                                                      nil,
                                                                                                      session_id)
                                         destination_object.parent_id = archived_documents_folder.id

                                         archived_documents_folder.get_file_path
                                       else
                                         root_path
                                       end
    base_filename                    = if file_path.present?
                                         File.basename(file_path).to_s
                                       else
                                         file.filename.to_s
                                       end
    
    FileUtils.mkpath(path) unless Dir.exist?(path)

    if file_path.present?
      destination_object.file_path   = get_unique_filename(path,
                                                           base_filename)

      File.open(file_path, 'rb') do |input_file|
        contents                     = input_file.read

        begin
          if destination_object.respond_to?(:upload_file)
            destination_object.upload_file.attach(io:       StringIO.new(contents),
                                                  filename: file_path)
          else
            destination_object.file.attach(io:       StringIO.new(contents),
                                           filename: file_path)
          end
        rescue Errno::EACCES
          if destination_object.respond_to?(:upload_file)
            destination_object.upload_file.attach(io:       StringIO.new(contents),
                                                  filename: file_path)
          else
            destination_object.file.attach(io:       StringIO.new(contents),
                                           filename: file_path)
          end
        end


        File.open(destination_object.file_path, 'wb') { |f| f.write(contents) }
      end
    else
      if destination_object.respond_to?(:upload_file)
        destination_object.upload_file.attach(io:           StringIO.new(file.download),
                                              filename:     file.filename,
                                              content_type: file.content_type)
      else
        destination_object.file.attach(io:           StringIO.new(file.download),
                                       filename:     file.filename,
                                       content_type: file.content_type)
      end

      if destination_object.respond_to?(:file_path)
        destination_object.file_path = get_unique_filename(path,
                                                           base_filename)

        File.open(destination_object.file_path, 'wb') { |f| f.write(file.download) }
      end
    end
  end

  def self.clone_object(object,
                        archive_id     = nil,
                        new_project_id = nil,
                        new_item_id    = nil,
                        session_id     = nil,
                        can_dup        = false,
                        excluded_items = DEFAULT_EXCLUDED_ITEMS)
    return nil unless object.present?

    archive_id               = if archive_id.present?
                                 archive_id
                               else
                                 archive             = Archive.new()
                                 identifier          = object.try(:description)
                                 identifier          = object.try(:full_id)    unless identifier.present?
                                 identifier          = object.try(:name)       unless identifier.present?
                                 identifier          = object.try(:title)      unless identifier.present?
                                 identifier          = object.try(:identifier) unless identifier.present?
                                 title               = "Archive of #{identifier}."
                                 archive.name        = title
                                 archive.full_id     = title
                                 archive.description = title
                                 archive.revision    = ''
                                 archive.version     = 0
                                 archive.archived_at = DateTime.now
                                 archive             = save_object(archive,
                                                                   'create',
                                                                   session_id)
                                 archive.id
                               end
    new_project_id           = object.project_id if !new_project_id.present? && object.try(:project_id).present?
    new_item_id              = object.item_id    if !new_item_id.present?    && object.try(:item_id).present?
    cloned_object            = if can_dup
                                 object.dup
                               else
                                 copy_attributes(object,
                                                 object.class.new(),
                                                 excluded_items)
                               end
    cloned_object.id         = nil
    cloned_object.archive_id = archive_id
    cloned_object.project_id = new_project_id           if cloned_object.respond_to?(:project_id)
    cloned_object.item_id    = new_item_id              if cloned_object.respond_to?(:item_id)
    file                     = object.try(:file)
    file                     = object.try(:upload_file) unless file.present?
    file_path                = object.try(:file_path)

    if (file_path.present? && File.exist?(file_path)) ||
       (file.present?      && file.attached?)
      clone_file(object, cloned_object, session_id)
    end

    object_item_id          = cloned_object.try(:item_id)
    cloned_object.item_id   = nil if object_item_id == 0
    cloned_object           = save_object(cloned_object, 'create', session_id)

    return cloned_object unless cloned_object.present?

    if object.try(:system_requirement_associations).present?     ||
       object.try(:high_level_requirement_associations).present? ||
       object.try(:low_level_requirement_associations).present?  ||
       object.try(:test_case_associations).present?
      return nil unless Associations.clone_associations(object,
                                                        cloned_object,
                                                        session_id)
    end

    if cloned_object.try(:model_file_id).present?
      cloned_object            = add_model_file(cloned_object,
                                                archive_id,
                                                object.project_id,
                                                object.item_id,
                                                new_item_id,
                                                session_id)
    end

    return cloned_object
  end

  def initialize(*)
    @archive_items                      = {}
    @high_level_requirements            = {}

    super
  end

  def unarchive(archive_id)
    result               = false
    table_names          = [
                              'document_comments',
                              'document_attachments',
                              'documents',
                              'action_items',
                              'checklist_items',
                              'review_attachments',
                              'reviews',
                              'test_procedures',
                              'test_cases',
                              'source_codes',
                              'module_descriptions',
                              'low_level_requirements',
                              'high_level_requirements',
                              'system_requirements',
                              'problem_report_histories',
                              'problem_report_attachments',
                              'problem_reports',
                              'items',
                              'projects'
                            ]

    ActiveRecord::Base.transaction do
      table_names.each do |table_name|
        rows             = table_name.singularize.classify.constantize.where(archive_id: archive_id)

        rows.each do |row|
          row.archive_id = nil

          row.save!
        end
      end

      result             = true
    end

    return result
  end

  def create_archive(project_id, session_id = nil)
    @archive_items                      = {}
    @high_level_requirements            = {}
    id_prefix                           = "#{full_id}_"
    project                             = Project.find(project_id)
    key                                 = Archive.generate_key(project)
    @archive_items[key]                 = project
    project                             = project.dup
    project.id                          = nil
    project.identifier                  = id_prefix + project.identifier
    project.archive_id                  = self.id

    ActiveRecord::Base.transaction do
      session_id                        = ChangeSession.get_session_id    unless session_id.present?
      @session_id                       = session_id
      project                           = Archive.save_object(project, 'create',
                                                              session_id)

      raise "Cannot Archive Project {project.identifier} "                 unless project.present?

      system_requirements               = clone_system_requirements(project_id,
                                                                    project.id,
                                                                    @session_id)

      raise "Cannot Archive System Requirements for {project.identifier} " if system_requirements.nil?

      problem_reports                   = clone_problem_reports(project_id,
                                                                project.id,
                                                                nil,
                                                                nil,
                                                                @session_id)

      raise "Cannot Archive Problem Reports for {project.identifier} "    if problem_reports.nil?

      items                             = clone_items(project_id, project.id,
                                                      @session_id)

      raise "Cannot Archive Items for {project.identifier} "              if items.nil?

      @archive_items.merge!(system_requirements) if @archive_items.present?
      @archive_items.merge!(problem_reports)     if @archive_items.present?
      @archive_items.merge!(items)               if @archive_items.present?

      @high_level_requirements.each do |hlr_key, high_level_requirement|
        next unless high_level_requirement.system_requirement_associations.present? ||
                    high_level_requirement.high_level_requirement_associations.present?

        id                              = Regexp.last_match(3).to_i       if hlr_key =~ /^high_level_requirements_(\d+)_(\d+)_(\d+)$/
        original_high_level_requirement = HighLevelRequirement.find(id)   if id.present?

        Associations.clone_associations(original_high_level_requirement,
                                        high_level_requirement,
                                        session_id)                       if original_high_level_requirement.present?
      end if @high_level_requirements.present?
    end

    return self
  end

  def clone_system_requirements(original_project_id, new_project_id, session_id)
    result                   = {}
    system_requirements      = SystemRequirement.where(project_id: original_project_id,
                                                       archive_id: nil)

    system_requirements.each do |system_requirement|
      key                    = Archive.generate_key(system_requirement)
      new_system_requirement = clone_system_requirement(system_requirement,
                                                        new_project_id,
                                                        session_id)

      return new_system_requirement unless new_system_requirement.present?

      result[key]            = new_system_requirement
    end

    return result
  end

  def clone_system_requirement(system_requirement, new_project_id, session_id)
    return Archive.clone_object(system_requirement, self.id,
                                new_project_id, nil, session_id)
  end

  def clone_items(original_project_id, new_project_id, session_id)
    result         = {}
    items          = Item.where(project_id: original_project_id,
                                archive_id: nil)

    items.each do |item|
      key          = Archive.generate_key(item)
      item         = clone_item(item, new_project_id, session_id)

      return nil unless item.present?

      result[key]  = item
    end

    return result
  end

  def clone_item(item, new_project_id, session_id)
    new_item                 = Archive.clone_object(item, self.id,
                                                    new_project_id, nil,
                                                    session_id, true)

    return new_item unless new_item.present?

    @high_level_requirements = clone_high_level_requirements(new_project_id,
                                                             item.id,
                                                             new_item.id,
                                                             session_id)

    return high_level_requirements if high_level_requirements.nil?

    low_level_requirements   = clone_low_level_requirements(new_project_id,
                                                            item.id,
                                                            new_item.id,
                                                            session_id)

    return low_level_requirements if low_level_requirements.nil?

    module_descriptions      = clone_module_descriptions(new_project_id,
                                                         item.id,
                                                         new_item.id,
                                                         session_id)

    return module_descriptions if module_descriptions.nil?

    source_codes             = clone_source_codes(new_project_id,
                                                  item.id,
                                                  new_item.id,
                                                  session_id)

    return source_codes if source_codes.nil?

    test_cases               = clone_test_cases(new_project_id,
                                                item.id,
                                                new_item.id,
                                                session_id)

    return test_cases if test_cases.nil?

    test_procedures          = clone_test_procedures(new_project_id,
                                                     item.id,
                                                     new_item.id,
                                                     session_id)

    return test_procedures if test_procedures.nil?

    documents                = clone_documents(new_project_id,
                                               item.id,
                                               new_item.id,
                                               session_id)

    return documents if documents.nil?

    reviews                  = clone_reviews(new_project_id,
                                             item.id,
                                             new_item.id,
                                             session_id)

    return reviews if reviews.nil?

    @archive_items.merge!(@high_level_requirements) if @archive_items.present?
    @archive_items.merge!(low_level_requirements)   if @archive_items.present?
    @archive_items.merge!(module_descriptions)      if @archive_items.present?
    @archive_items.merge!(source_codes)             if @archive_items.present?
    @archive_items.merge!(test_cases)               if @archive_items.present?
    @archive_items.merge!(test_procedures)          if @archive_items.present?
    @archive_items.merge!(documents)                if @archive_items.present?
    @archive_items.merge!(reviews)                  if @archive_items.present?

    return new_item
  end

  def clone_high_level_requirements(project_id, original_item_id, new_item_id,
                                    session_id)
    result                   = {}
    high_level_requirements  = HighLevelRequirement.where(item_id:    original_item_id,
                                                          archive_id: nil)

    high_level_requirements.each do |high_level_requirement|
      key                    = Archive.generate_key(high_level_requirement)
      high_level_requirement = clone_high_level_requirement(high_level_requirement,
                                                            project_id,
                                                            new_item_id,
                                                            session_id)

      return nil unless high_level_requirement.present?

      result[key]            = high_level_requirement
    end

    return result
  end

  def clone_high_level_requirement(high_level_requirement,
                                   project_id,
                                   new_item_id,
                                   session_id)
    return Archive.clone_object(high_level_requirement, self.id,
                                project_id, new_item_id, session_id)
  end

  def clone_low_level_requirements(project_id,
                                   original_item_id,
                                   new_item_id,
                                   session_id)
    result                  = {}
    low_level_requirements  = LowLevelRequirement.where(item_id:    original_item_id,
                                                        archive_id: nil)

    low_level_requirements.each do |low_level_requirement|
      key                   = Archive.generate_key(low_level_requirement)
      low_level_requirement = clone_low_level_requirement(low_level_requirement,
                                                          project_id,
                                                          new_item_id,
                                                          session_id)

      return nil unless low_level_requirement.present?

      result[key]            = low_level_requirement
    end

    return result
  end

  def clone_low_level_requirement(low_level_requirement,
                                  project_id,
                                  new_item_id,
                                  session_id)
    return Archive.clone_object(low_level_requirement, self.id,
                                project_id, new_item_id, session_id)
  end

  def clone_model_files(project_id, original_item_id, new_item_id, session_id)
    result           = {}
    model_files      = ModelFile.where(item_id: original_item_id, archive_id: nil)

    model_files.each do |model_file|
      key            = Archive.generate_key(model_file)
      new_model_file = clone_model_file(model_file, project_id, new_item_id,
                                        session_id)

      return nil unless new_model_file.present?

      result[key]    = new_model_file
    end

    return result
  end

  def clone_model_file(model_file, project_id, new_item_id, session_id)
    return Archive.clone_object(model_file, self.id, project_id, new_item_id,
                                session_id)
  end

  def clone_module_descriptions(project_id, original_item_id, new_item_id,
                                session_id)
    result              = {}
    module_descriptions = ModuleDescription.where(item_id:    original_item_id,
                                                  archive_id: nil)

    module_descriptions.each do |module_description|
      key                    = Archive.generate_key(module_description)
      new_module_description = clone_module_description(module_description,
                                                        project_id,
                                                        new_item_id,
                                                        session_id)

      return nil unless new_module_description.present?

      result[key]     = new_module_description
    end

    return result
  end

  def clone_module_description(module_description, project_id, new_item_id,
                               session_id)
    return Archive.clone_object(module_description, self.id, project_id,
                                new_item_id, session_id)
  end

  def clone_source_codes(project_id, original_item_id, new_item_id, session_id)
    result            = {}
    source_codes      = SourceCode.where(item_id:    original_item_id,
                                         archive_id: nil)

    source_codes.each do |source_code|
      key             = Archive.generate_key(source_code)
      new_source_code = clone_source_code(source_code, project_id, new_item_id,
                                          session_id)

      return nil unless new_source_code.present?

      result[key]     = new_source_code
    end

    return result
  end

  def clone_source_code(source_code, project_id, new_item_id, session_id)
    return Archive.clone_object(source_code, self.id, project_id, new_item_id,
                                session_id)
  end

  def clone_test_cases(project_id, original_item_id, new_item_id, session_id)
    result          = {}
    test_cases      = TestCase.where(item_id:    original_item_id,
                                     archive_id: nil)

    test_cases.each do |test_case|
      key           = Archive.generate_key(test_case)
      new_test_case = clone_test_case(test_case, project_id, new_item_id,
                                      session_id)

      return nil unless new_test_case.present?

      result[key]   = new_test_case
    end

    return result
  end

  def clone_test_case(test_case, project_id, new_item_id, session_id)
    return Archive.clone_object(test_case, self.id, project_id, new_item_id,
                                session_id)
  end

  def clone_test_procedures(project_id, original_item_id, new_item_id,
                            session_id)
    result          = {}
    test_procedures = TestProcedure.where(item_id:    original_item_id,
                                          archive_id: nil)

    test_procedures.each do |test_procedure|
      key                = Archive.generate_key(test_procedure)
      new_test_procedure = clone_test_procedure(test_procedure, project_id,
                                                new_item_id, session_id)

      return nil unless new_test_procedure.present?

      result[key]        = new_test_procedure
    end

    return result
  end

  def clone_test_procedure(test_procedure, project_id, new_item_id, session_id)
    return Archive.clone_object(test_procedure, self.id, project_id,
                                new_item_id, session_id)
  end

  def clone_documents(project_id, original_item_id, new_item_id, session_id)
    result         = {}
    documents      = Document.where(item_id: original_item_id, archive_id: nil)

    documents.each do |document|
      key          = Archive.generate_key(document)
      new_document = clone_document(document, project_id, new_item_id,
                                    session_id)

      return nil unless new_document.present?

      result[key]  = new_document
    end

    return result
  end

  def clone_document(document, project_id, new_item_id, session_id)
    new_document = Archive.clone_object(document, self.id, project_id,
                                        new_item_id, session_id)

    return new_document unless new_document.present?

    document_comments      = clone_document_comments(project_id,
                                                     new_item_id,
                                                     document.id,
                                                     new_document.id,
                                                     session_id)

    return document_comments if document_comments.nil?

    document_attachments   = clone_document_attachments(project_id,
                                                        new_item_id,
                                                        document.id,
                                                        new_document.id,
                                                        session_id)

    return document_attachments if document_attachments.nil?

    @archive_items.merge!(document_comments)    if @archive_items.present?
    @archive_items.merge!(document_attachments) if @archive_items.present?

    return new_document
  end

  def clone_document_comments(project_id, new_item_id, original_document_id,
                              new_document_id, session_id)
    result                 = {}
    document_comments      = DocumentComment.where(document_id: original_document_id,
                                                   archive_id:  nil)

    document_comments.each do |document_comment|
      key                  = Archive.generate_key(document_comment)
      new_document_comment = clone_document_comment(document_comment,
                                                    project_id,
                                                    new_item_id,
                                                    new_document_id,
                                                    session_id)

      return nil unless new_document_comment.present?

      result[key] = new_document_comment
    end

    return result
  end

  def clone_document_comment(document_comment, project_id, new_item_id,
                             new_document_id, session_id)
    new_document_comment             = Archive.clone_object(document_comment,
                                                            self.id,
                                                            project_id,
                                                            new_item_id,
                                                            session_id,
                                                            true)

    return new_document_comment unless new_document_comment.present?

    new_document_comment.document_id = new_document_id
    new_document_comment             = Archive.save_object(new_document_comment,
                                                           'update',
                                                           session_id)

    return new_document_comment
  end

  def clone_document_attachments(project_id, new_item_id, original_document_id,
                                 new_document_id, session_id)
    result                    = {}
    document_attachments      = DocumentAttachment.where(document_id: original_document_id,
                                                         archive_id:  nil)

    document_attachments.each do |document_attachment|
      key                     = Archive.generate_key(document_attachment)
      new_document_attachment = clone_document_attachment(document_attachment,
                                                          project_id,
                                                          new_item_id,
                                                          new_document_id,
                                                          session_id)

      return nil unless new_document_attachment.present?

      result[key]             = new_document_attachment
    end

    return result
  end

  def clone_document_attachment(document_attachment, project_id, new_item_id,
                                new_document_id, session_id)
    new_document_attachment             = Archive.clone_object(document_attachment,
                                                               self.id,
                                                               project_id,
                                                               new_item_id,
                                                               session_id,
                                                               false,
                                                               )

    return new_document_attachment unless new_document_attachment.present?

    new_document_attachment.document_id = new_document_id
    new_document_attachment             = Archive.save_object(new_document_attachment,
                                                              'update',
                                                              session_id)

    return new_document_attachment
  end

  def clone_reviews(project_id, original_item_id, new_item_id, session_id)
    result        = {}
    reviews       = Review.where(item_id: original_item_id, archive_id: nil)

    reviews.each do |review|
      key         = Archive.generate_key(review)
      new_review  = clone_review(review, project_id, new_item_id, session_id)

      return nil unless new_review.present?

      result[key] = new_review
    end

    return result
  end

  def clone_review(review, project_id, new_item_id, session_id)
    new_review      =  Archive.clone_object(review, self.id, project_id,
                                            new_item_id, session_id, true)

    return new_review unless new_review.present?

    review_attachments = clone_review_attachments(project_id, new_item_id,
                                                  review.id, new_review.id,
                                                  session_id)

    return review_attachments if review_attachments.nil?

    checklist_items = clone_checklists(review.id, new_review.id, session_id)

    return checklist_items if checklist_items.nil?

    action_items    = clone_action_items(project_id, new_item_id, review.id,
                                         new_review.id, session_id)

    return action_items if action_items.nil?

    @archive_items.merge!(review_attachments) if @archive_items.present?
    @archive_items.merge!(checklist_items)    if @archive_items.present?
    @archive_items.merge!(action_items)       if @archive_items.present?

    return new_review
  end

  def clone_review_attachments(project_id, new_item_id, original_review_id,
                               new_review_id, session_id)
    result                  = {}
    review_attachments      = ReviewAttachment.where(review_id:  original_review_id,
                                                     archive_id: nil)

    review_attachments.each do |review_attachment|
      key                   = Archive.generate_key(review_attachment)
      new_review_attachment = clone_review_attachment(review_attachment,
                                                      project_id,
                                                      new_item_id,
                                                      new_review_id,
                                                      session_id)

      return nil unless new_review_attachment.present?

      result[key] = new_review_attachment
    end

    return result
  end

  def clone_review_attachment(review_attachment, project_id, new_item_id,
                              new_review_id, session_id)
    new_review_attachment           = Archive.clone_object(review_attachment,
                                                           self.id,
                                                           project_id,
                                                           new_item_id,
                                                           session_id,
                                                           false)

    return new_review_attachment unless new_review_attachment.present?

    new_review_attachment.review_id = new_review_id
    new_review_attachment           = Archive.save_object(new_review_attachment,
                                                          'update',
                                                          session_id)

    return new_review_attachment
  end

  def clone_checklists(original_review_id, new_review_id, session_id)
    result               = {}
    checklist_items      = ChecklistItem.where(review_id:  original_review_id,
                                               archive_id: nil)

    checklist_items.each do |checklist_item|
      key                = Archive.generate_key(checklist_item)
      new_checklist_item = clone_checklist(checklist_item,
                                           original_review_id,
                                           new_review_id,
                                           session_id)

      return nil unless new_checklist_item.present?

      result[key]        = new_checklist_item
    end

    return result
  end

  def clone_checklist(checklist_item, original_review_id, new_review_id,
                      session_id)
    new_checklist_item            = Archive.clone_object(checklist_item,
                                                         self.id, nil, nil,
                                                         session_id, true)

    return new_checklist_item unless new_checklist_item.present?

    new_checklist_item.review_id  = new_review_id
    new_checklist_item            = Archive.save_object(new_checklist_item,
                                                        'update', session_id)

    return new_checklist_item
  end

  def clone_action_items(project_id, new_item_id, original_review_id,
                         new_review_id, session_id)
    result            = {}
    action_items      = ActionItem.where(review_id:  original_review_id,
                                         archive_id: nil)

    action_items.each do |action_item|
      key             = Archive.generate_key(action_item)
      new_action_item = clone_action_item(action_item, project_id, new_item_id,
                                          new_review_id, session_id)

      return nil unless new_action_item.present?

      result[key] = new_action_item
    end

    return result
  end

  def clone_action_item(action_item, project_id, new_item_id, new_review_id,
                        session_id)
    new_action_item           = Archive.clone_object(action_item,
                                                     self.id,
                                                     project_id,
                                                     new_item_id,
                                                     session_id,
                                                     true)

    return new_action_item unless new_action_item.present?

    new_action_item.review_id = new_review_id
    new_action_item           = Archive.save_object(new_action_item,
                                                    'update',
                                                    session_id)

    return new_action_item
  end

  def clone_problem_reports(original_project_id, new_project_id,
                            original_item_id, new_item_id, session_id)
    result               = {}
    problem_reports      = ProblemReport.where(item_id:    original_item_id,
                                               archive_id: nil) if     original_item_id.present?
    problem_reports      = ProblemReport.where(project_id: original_project_id,
                                               archive_id: nil) unless problem_reports.present?

    problem_reports.each do |problem_report|
      key                = Archive.generate_key(problem_report)
      new_problem_report = clone_problem_report(problem_report,
                                                new_project_id,
                                                new_item_id,
                                                session_id)

      return nil unless problem_report.present?

      result[key] = new_problem_report
    end

    return result
  end

  def clone_problem_report(problem_report, project_id, new_item_id, session_id)
    new_problem_report         = Archive.clone_object(problem_report, self.id,
                                                      project_id, new_item_id,
                                                      session_id, true)

    return new_problem_report unless new_problem_report.present?

    problem_report_histories   = clone_problem_report_histories(project_id,
                                                                problem_report.id,
                                                                new_problem_report.id,
                                                                session_id)

    return problem_report_histories if problem_report_histories.nil?

    problem_report_attachments = clone_problem_report_attachments(project_id,
                                                                  new_item_id,
                                                                  problem_report.id,
                                                                  new_problem_report.id,
                                                                  session_id)

    return problem_report_attachments if problem_report_attachments.nil?

    @archive_items.merge!(problem_report_attachments) if @archive_items.present?
    @archive_items.merge!(problem_report_histories)   if @archive_items.present?

    return new_problem_report
  end

  def clone_problem_report_histories(project_id, original_problem_report_id,
                                     new_problem_report_id, session_id)
    result                       = {}
    problem_report_histories     = ProblemReportHistory.where(problem_report_id: original_problem_report_id,
                                                              archive_id:        nil)

    problem_report_histories.each do |problem_report_history|
      key                        = Archive.generate_key(problem_report_history)
      new_problem_report_history = clone_problem_report_history(problem_report_history,
                                                                project_id,
                                                                original_problem_report_id,
                                                                new_problem_report_id,
                                                                session_id)

      return nil unless new_problem_report_history.present?

      result[key] = new_problem_report_history
    end

    return result
  end

  def clone_problem_report_history(problem_report_history, project_id,
                                   original_problem_report_id,
                                   new_problem_report_id, session_id)
    new_problem_report_history                    = Archive.clone_object(problem_report_history,
                                                                         self.id,
                                                                         project_id,
                                                                         nil,
                                                                         session_id,
                                                                         true)

    return new_problem_report_history unless new_problem_report_history.present?

    new_problem_report_history.problem_report_id  = new_problem_report_id
    new_problem_report_history                    = Archive.save_object(new_problem_report_history,
                                                                        'update',
                                                                        session_id)

    return new_problem_report_history
  end

  def clone_problem_report_attachments(project_id, new_item_id,
                                       original_problem_report_id,
                                       new_problem_report_id,
                                       session_id)
    result                          = {}
    problem_report_attachments      = ProblemReportAttachment.where(problem_report_id: original_problem_report_id,
                                                                    archive_id:        nil)

    problem_report_attachments.each do |problem_report_attachment|
      key                           = Archive.generate_key(problem_report_attachment)
      new_problem_report_attachment = clone_problem_report_attachment(problem_report_attachment,
                                                                      project_id,
                                                                      new_item_id,
                                                                      new_problem_report_id,
                                                                      session_id)

      return nil unless new_problem_report_attachment.present?

      result[key] = new_problem_report_attachment
    end

    return result
  end

  def clone_problem_report_attachment(problem_report_attachment, project_id,
                                      new_item_id, new_problem_report_id,
                                      session_id)
    new_problem_report_attachment                   = Archive.clone_object(problem_report_attachment,
                                                                           self.id,
                                                                           project_id,
                                                                           new_item_id,
                                                                           session_id,
                                                                           false)

    return new_problem_report_attachment unless new_problem_report_attachment.present?

    new_problem_report_attachment.problem_report_id = new_problem_report_id
    new_problem_report_attachment                   = Archive.save_object(new_problem_report_attachment,
                                                                          'update',
                                                                          session_id)

    return new_problem_report_attachment
  end
end
