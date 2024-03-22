class PopulateTemplates
  DEFAULT_TEMPLATES_FOLDER = Rails.root.join('app', 'templates')
  DEFAULT_ORGANIZATION     = 'global'
  DEFAULT_USER_EMAIL       = 'paul@patmos-eng.com'
  EXTENSION_FILETYPES      = {
                               'aac'    => 'audio/aac',
                               'abw'    => 'application/x-abiword',
                               'arc'    => 'application/x-freearc',
                               'avi'    => 'video/x-msvideo',
                               'azw'    => 'application/vnd.amazon.ebook',
                               'bin'    => 'application/octet-stream',
                               'bmp'    => 'image/bmp',
                               'bz'     => 'application/x-bzip',
                               'bz2'    => 'application/x-bzip2',
                               'csh'    => 'application/x-csh',
                               'css'    => 'text/css',
                               'csv'    => 'text/csv',
                               'doc'    => 'application/msword',
                               'docx'   => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                               'eot'    => 'application/vnd.ms-fontobject',
                               'epub'   => 'application/epub+zip',
                               'gz'     => 'application/gzip',
                               'gif'    => 'image/gif',
                               'html'   => 'text/html',
                               'ico'    => 'image/vnd.microsoft.icon',
                               'ics'    => 'text/calendar',
                               'jar'    => 'application/java-archive',
                               'jpg'    => 'image/jpeg',
                               'js'     => 'JavaScript ',
                               'json'   => 'application/json',
                               'jsonld' => 'application/ld+json',
                               'midi'   => 'audio/x-midi',
                               'mjs'    => 'text/javascript',
                               'mp3'    => 'audio/mpeg',
                               'mpeg'   => 'video/mpeg',
                               'mpkg'   => 'application/vnd.apple.installer+xml',
                               'odp'    => 'application/vnd.oasis.opendocument.presentation',
                               'ods'    => 'application/vnd.oasis.opendocument.spreadsheet',
                               'odt'    => 'application/vnd.oasis.opendocument.text',
                               'oga'    => 'audio/ogg',
                               'ogv'    => 'video/ogg',
                               'ogx'    => 'application/ogg',
                               'opus'   => 'audio/opus',
                               'otf'    => 'font/otf',
                               'png'    => 'image/png',
                               'pdf'    => 'application/pdf',
                               'php'    => 'application/x-httpd-php',
                               'ppt'    => 'application/vnd.ms-powerpoint',
                               'pptx'   => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                               'rar'    => 'application/vnd.rar',
                               'rtf'    => 'application/rtf',
                               'sh'     => 'application/x-sh',
                               'svg'    => 'image/svg+xml',
                               'swf'    => 'application/x-shockwave-flash',
                               'tar'    => 'application/x-tar',
                               'tiff'   => 'image/tiff',
                               'ts'     => 'video/mp2t',
                               'ttf'    => 'font/ttf',
                               'txt'    => 'text/plain',
                               'vsd'    => 'application/vnd.visio',
                               'wav'    => 'audio/wav',
                               'weba'   => 'audio/webm',
                               'webm'   => 'video/webm',
                               'webp'   => 'image/webp',
                               'woff'   => 'font/woff',
                               'woff2'  => 'font/woff2',
                               'xhtml'  => 'application/xhtml+xml',
                               'xls'    => 'application/vnd.ms-excel',
                               'xlsx'   => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                               'xml'    => 'text/xml',
                               'xul'    => 'application/vnd.mozilla.xul+xml',
                               'zip'    => 'application/zip',
                               '3gp'    => 'video/3gpp',
                               '3g2'    => 'video/3gpp2',
                               '7z'     => 'application/x-7z-compressed'
                             }

  @@document_templates_path = nil

  def get_root_path
    path                                = ''

    unless @@document_templates_path.present?
      local                             = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root                              = local['root']                        if local.present?
      @@document_templates_path         = File.join(root,
                                                    'templates',
                                                    User.current.organization) if root.present?
    end

    path                                = @@document_templates_path
  end

  def get_file_path(type = 'documents')
    File.join(get_root_path, type)
  end

  def file_type_from_filename(filename)
    extension = Regexp.last_match(1).downcase if filename =~ /.*\.(.+)$/i
    file_type = EXTENSION_FILETYPES[extension] if extension.present?

    if file_type.present?
      file_type
    else
      'text/plain'
    end
  end

  def delete_organization_checklists(organization = User.current.try(:organization))
    organization             = DEFAULT_ORGANIZATION unless organization.present?
    template_checklist_items = TemplateChecklistItem.where(organization: organization,
                                                           source:       Constants::AWC)
    template_checklists      = TemplateChecklist.where(organization:     organization,
                                                       source:           Constants::AWC)

    template_checklist_items.each { |item|      item.destroy }      if template_checklist_items.present?
    template_checklists.each      { |checklist| checklist.destroy } if template_checklists.present?
  end

  def delete_organization_documents(organization = User.current.try(:organization))
    organization       = DEFAULT_ORGANIZATION unless organization.present?
    template_documents = TemplateDocument.where(organization: organization,
                                                source:       Constants::AWC)

    template_documents.each { |document| document.destroy } if template_documents.present?
  end

  def delete_organization_templates(organization = User.current.try(:organization))
    organization = DEFAULT_ORGANIZATION unless organization.present?
    templates    = Template.where(organization: organization,
                                  source:       Constants::AWC)

    delete_organization_checklists(organization)
    delete_organization_documents(organization)

    templates.each { |template| template.destroy } if templates.present?
  end

  def populate_checklists(template_checklist_path,
                          checklist_type  = 'Peer Review',
                          checklist_class = 'DO-1768',
                          template_id     = nil,
                          organization    = User.current.try(:organization))
    result                               = false
    organization                         = DEFAULT_ORGANIZATION unless organization.present?

    return "#{template_checklist_path} does not exist." unless template_checklist_path.present? &&
                                                               Dir.exists?(template_checklist_path)

    checklists                           = Dir.glob(template_checklist_path.join('*.xlsx'))

    checklists.each do |checklist|
      description                        = ''
      basename                           = File.basename(checklist)
      name                               = if basename =~ /.*\-([A-Z]+)\.(FINAL|final|Final).*$/
                                            Regexp.last_match(1)
                                           elsif basename =~ /.*\.(.*)\-checklist\.final.*$/i
                                            Regexp.last_match(1).gsub('-', ' ')
                                           elsif basename =~ /.*\-checklist\-(.*)\.final.*$/i
                                            Regexp.last_match(1).gsub('-', ' ')
                                           elsif basename =~ /(.+)\.xls$/i
                                            Regexp.last_match(1)
                                           else
                                             basename
                                           end
      max_id                             = if template_id.present?
                                             TemplateChecklist.where(template_id:  template_id,
                                                                     source:       Constants::AWC,
                                                                     organization: organization).maximum(:clid)
                                           else
                                             TemplateChecklist.where(source:       Constants::AWC,
                                                                     organization: organization).maximum(:clid)
                                          end

      if checklist_type  == 'Peer Review'
        info                             = Constants::DocumentType[name]
        description                      = if info.present?
                                             info[:description]
                                           else
                                             name
                                           end
      else
        description                      = name
      end

      template_checklist                 = TemplateChecklist.new
      template_checklist.clid            = max_id.present? ? max_id.next : 1
      template_checklist.template_id     = template_id
      template_checklist.title           = description
      template_checklist.description     = description
      template_checklist.notes           = "Imported from #{checklist}."
      template_checklist.checklist_class = checklist_class
      template_checklist.checklist_type  = checklist_type
      template_checklist.source          = Constants::AWC
      template_checklist.draft_revision  = '0.0'
      template_checklist.version         = 1
      template_checklist.organization    = organization
      template_checklist.filename        = checklist

      template_checklist.save!

      return "Cannot create checklist for #{filename}" unless template_checklist.from_patmos_template(checklist)
    end if checklists.present?

    return result
  end

  def create_template_document(filename,
                               template_id     = nil,
                               document_class  = 'DO-178',
                               organization = User.current.try(:organization))
    return nil unless filename.present? && File.readable?(filename)

    organization                        = DEFAULT_ORGANIZATION unless organization.present?
    template_documents                  = []
    basename                            = File.basename(filename)
    name                                = if basename =~ /^\d+_(.+?)\..*\.doc$/i
                                            Regexp.last_match(1)
                                          elsif basename =~ /^(.+?)\..*\.doc$/i
                                            Regexp.last_match(1)
                                          elsif basename =~ /^(.+?)\.doc$/i
                                            Regexp.last_match(1)
                                          else
                                            basename
                                          end
    fields                              = name.split('_') if name.present?
    name                                = fields.last     if fields.present?
    file_type                           = file_type_from_filename(basename)
    info                                = Constants::DocumentType[name]
    directory                           = get_file_path()

    FileUtils.mkpath(directory) unless Dir.exist?(directory)

    if info.present?
      info[:dals].each_with_index do |dal,index|
        max_id                            = if template_id.present?
                                              TemplateDocument.where(template_id:  template_id,
                                                                     source:       Constants::AWC,
                                                                     organization: organization).maximum(:document_id)
                                            else
                                              TemplateDocument.where(source:       Constants::AWC,
                                                                     organization: organization).maximum(:document_id)
                                            end
        template_document                 = TemplateDocument.new
        template_document.document_id     = max_id.present? ? max_id.next : 1
        template_document.title           = "#{name}-#{dal}"
        template_document.docid           = template_document.title
        template_document.name            = template_document.title
        template_document.notes           = "Imported from #{filename}."
        template_document.description     = info[:description]
        template_document.template_id     = template_id
        template_document.document_class  = info[:class]
        template_document.dal             = dal
        template_document.category        = info[:category][index]
        template_document.document_type   = 'Template'
        template_document.file_type       = file_type
        template_document.source          = Constants::AWC
        template_document.draft_revision  = '0.0'
        template_document.version         = 1
        template_document.organization    = organization
        template_document.filename        = File.join(directory, basename)

        begin
          FileUtils.copy(filename, template_document.filename)

          File.open(filename, 'r') do |file|
            template_document.file.attach(io:           file,
                                          filename:     basename,
                                          content_type: file_type)
          end
        rescue Errno::EACCES
          FileUtils.copy(filename, template_document.filename)

          File.open(filename, 'r') do |file|
            template_document.file.attach(io:           file,
                                          filename:     basename,
                                          content_type: file_type)
          end
        end

        template_document.save!
        template_documents.push(template_document)
      end if info[:dals].present?
    else
      max_id                            = if template_id.present?
                                            TemplateDocument.where(template_id:  template_id,
                                                                   source:       Constants::AWC,
                                                                   organization: organization).maximum(:document_id)
                                          else
                                            TemplateDocument.where(source:       Constants::AWC,
                                                                   organization: organization).maximum(:document_id)
                                          end
      template_document                 = TemplateDocument.new
      template_document.document_id     = max_id.present? ? max_id.next : 1
      template_document.title           = name
      template_document.docid           = template_document.title
      template_document.name            = template_document.title
      template_document.notes           = "Imported from #{filename}."
      template_document.description     = ''
      template_document.template_id     = template_id
      template_document.document_class  = document_class
      template_document.file_type       = file_type
      template_document.document_type   = 'Template'
      template_document.source          = Constants::AWC
      template_document.draft_revision  = '0.0'
      template_document.version         = 1
      template_document.organization    = organization

      begin
        File.open(filename, 'r') do |file|
          template_document.file.attach(io:           file,
                                        filename:     basename,
                                        content_type: file_type)
        end
      rescue Errno::EACCES
        File.open(filename, 'r') do |file|
          template_document.file.attach(io:           file,
                                        filename:     basename,
                                        content_type: file_type)
        end
      end

      template_document.save!
      template_documents.push(template_document)
    end

    return template_documents
  end

  def populate_documents(template_document_path,
                         template_id     = nil,
                         document_class  = 'DO-178',
                         organization = User.current.try(:organization))
    organization = DEFAULT_ORGANIZATION unless organization.present?
    result       = ''

    return "#{template_document_path} does not exist." unless template_document_path.present? &&
                                                              Dir.exists?(template_document_path)

    documents    = Dir.glob(template_document_path.join('*.doc'))

    documents.each do |document|
      return "Cannot create document template for #{document}" unless create_template_document(document,
                                                                                               template_id,
                                                                                               document_class,
                                                                                               organization).present?
    end if documents.present?

    return result
  end

  def create_template(template_class,
                      organization = User.current.try(:organization))
    organization            = DEFAULT_ORGANIZATION unless organization.present?
    max_id                  = Template.where(source:       Constants::AWC,
                                             organization: organization).maximum(:tlid)
    template                = Template.new
    template.tlid           = max_id.present? ? max_id.next : 1
    template.template_class = template_class
    template.title          = "ACS #{template_class} Templates"
    template.description    = "Airworthiness Certification Services #{template_class} Templates"
    template.notes          = "Master Airworthiness Certification Services #{template_class} Templates Created #{DateTime.now()} by populate_templates."
    template.template_type  = 'Master ACS Templates'
    template.source         = Constants::AWC

    template.save!

    template
  end

  def populate_templates(templates_folder_path = DEFAULT_TEMPLATES_FOLDER,
                         user_email            = User.current.try(:email),
                         organization          = User.current.try(:organization),
                         db_name               = 'pact_awc')
    user_email                        = DEFAULT_USER_EMAIL   unless user_email.present?
    organization                      = DEFAULT_ORGANIZATION unless organization.present?
    result                            = ''

    unless User.current.present?
      User.set_database(db_name)

      user                            = User.find_by(email: user_email)
      User.current                    = user if user.present?
    end

    return "#{templates_folder_path} does not exist." unless templates_folder_path.present? &&
                                                             Dir.exists?(templates_folder_path)

    do_178_templates_path             = templates_folder_path.join('do-178')

    return "#{do_178_templates_path} does not exist." unless Dir.exists?(do_178_templates_path)

    do_178_checklists_path            = do_178_templates_path.join('checklists')

    return "#{do_178_checklists_path} does not exist." unless Dir.exists?(do_178_checklists_path)

    do_178_documents_path             = do_178_templates_path.join('documents')

    return "#{do_178_documents_path} does not exist." unless Dir.exists?(do_178_documents_path)

    do_178_peer_checklists_path       = do_178_checklists_path.join('peer')

    return "#{do_178_peer_checklists_path} does not exist." unless Dir.exists?(do_178_peer_checklists_path)

    do_178_transition_checklists_path = do_178_checklists_path.join('transition')

    return "#{do_178_transition_checklists_path} does not exist." unless Dir.exists?(do_178_transition_checklists_path)

    do_254_templates_path             = templates_folder_path.join('do-254')

    return "#{do_254_templates_path} does not exist." unless Dir.exists?(do_254_templates_path)

    do_254_checklists_path            = do_254_templates_path.join('checklists')

    return "#{do_254_checklists_path} does not exist." unless Dir.exists?(do_254_checklists_path)

    do_254_documents_path             = do_254_templates_path.join('documents')

    return "#{do_254_documents_path} does not exist." unless Dir.exists?(do_254_documents_path)

    do_254_peer_checklists_path       = do_254_checklists_path.join('peer')

    return "#{do_254_peer_checklists_path} does not exist." unless Dir.exists?(do_254_peer_checklists_path)

    do_254_transition_checklists_path = do_254_checklists_path.join('transition')

    return "#{do_254_transition_checklists_path} does not exist." unless Dir.exists?(do_254_transition_checklists_path)

    ApplicationController.new.set_current_database(organization)

    ActiveRecord::Base.transaction do
      user                            = User.find_by(email: user_email, organization: organization)
      user                            = User.current unless user.present?

      if user.present?
        original_organization         = user.organization
        user.organization             = organization
        User.current                  = user
        user.save!
      end

      delete_organization_templates(organization)

      do_178_template                 = create_template('DO-178', organization)
      result                          = 'Cannot create DO-178 Template.' unless do_178_template.present?

      raise ActiveRecord::Rollback, result if result.present?

      do_254_template                 = create_template('DO-254', organization)
      result                          = 'Cannot create DO-254 Template.' unless do_254_template.present?

      raise ActiveRecord::Rollback, result if result.present?

      result                          = populate_documents(do_178_documents_path,
                                                           do_178_template.id,
                                                           'DO-178', organization)

      raise ActiveRecord::Rollback, result if result.present?

      result                          = populate_documents(do_254_documents_path,
                                                           do_254_template.id,
                                                           'DO-254',
                                                           organization)

      raise ActiveRecord::Rollback, result if result.present?

      result                          = populate_checklists(do_178_peer_checklists_path,
                                                            'Peer Review',
                                                            'DO-178',
                                                            do_178_template.id,
                                                            organization)

      raise ActiveRecord::Rollback, result if result.present?

      result                          = populate_checklists(do_254_peer_checklists_path,
                                                            'Peer Review',
                                                            'DO-254',
                                                            do_254_template.id,
                                                            organization)

      raise ActiveRecord::Rollback, result if result.present?

      result                          = populate_checklists(do_178_transition_checklists_path,
                                                            'Transition Review',
                                                            'DO-178',
                                                            do_178_template.id,
                                                            organization)

      raise ActiveRecord::Rollback, result if result.present?

      result                          = populate_checklists(do_254_transition_checklists_path,
                                                            'Transition Review',
                                                            'DO-254',
                                                            do_254_template.id,
                                                            organization)

      raise ActiveRecord::Rollback, result if result.present?

      result                         = ''

      user.organization              = original_organization
      user.save!
    end

    ApplicationController.new.restore_database

    return result
  end
end
