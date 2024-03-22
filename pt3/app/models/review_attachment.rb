class ReviewAttachment < OrganizationRecord
  belongs_to :review, optional: true
  belongs_to :item, optional: true
  belongs_to :project, optional: true
  # Validations
  validates :review_id, presence: true
  validates :project_id, presence: true
  validates :item_id, presence: true
  validates :user, presence: true
  # Files
  has_one_attached :file, dependent: false
  # Validate only size. Do not validate if file is not attached.
  validates :file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { file.attached? }

  attr_accessor :pact_file

  @@review_attachments_path = nil

  def get_root_path
    path   = ''

    unless @@review_attachments_path.present?
      local                     = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root                      = local['root']                        if local.present?
      @@review_attachments_path = File.join(root,
                                            'review_attachments',
                                            User.current.organization) if root.present?
    end

    path = @@review_attachments_path
  end

  def get_file_path
    if self.file_path.present?
      File.join(get_root_path, File.basename(self.file_path))
    else
      get_root_path
    end
  end

  def get_file_contents
    result         = nil

    return unless self.link_type.present?

    case(self.link_type)
      when Constants::UPLOAD_ATTACHMENT
        result     = self.file if self.file.attached?

      when Constants::EXTERNAL_ATTACHMENT
        result     =  URI.parse(self.link_link) if self.link_link.present?

      when Constants::INSTRUMENTS_ATTACHMENT
        result     = File.read(self.link_link) if File.readable?(self.link_link)

      when Constants::PACT_ATTACHMENT
        if self.link_link =~ /.*\/(\d+)$/
          document = Document.find(Regexp.last_match[1])
        end

        result     = document.get_file_contents if document.present?
    end

    return result
  end

  def replace_file(file, session_id = nil)
    result           = false

    return result unless file.present?

    self.upload_date = DateTime.now

    if file.instance_of?(ActiveStorage::Attached::One)
      begin
        self.file.attach(io:           StringIO.new(file.download),
                         filename:     file.filename,
                         content_type: file.content_type)
      rescue Errno::EACCES
        self.file.attach(io:           StringIO.new(file.download),
                         filename:     file.filename,
                         content_type: file.content_type)
      end
    elsif file.instance_of?(ActionDispatch::Http::UploadedFile)
      return result unless file.tempfile.present?

      file.tempfile.rewind

      begin
        self.file.attach(io:           file.tempfile,
                         filename:     file.original_filename,
                         content_type: file.content_type)
      rescue Errno::EACCES
        self.file.attach(io:           file.tempfile,
                         filename:     file.original_filename,
                         content_type: file.content_type)
      end
    end

    result = true if DataChange.save_or_destroy_with_undo_session(self,
                                                                  'update',
                                                                  self.id,
                                                                  'review_attachments',
                                                                  session_id)

    return result
  end

  def setup_attachment(link_link,
                       link_description = link_link,
                       link_type        = Constants::EXTERNAL_ATTACHMENT,
                       attachment_type  = Constants::REFERENCE_ATTACHMENT,
                       pact_file        = nil,
                       file             = nil,
                       session_id       = nil)
    error                     = ''
    okay                      = true
    self.attachment_type      = attachment_type
    self.link_type            = link_type
    self.link_description     = link_description
    self.link_link            = link_link

    if self.link_type == Constants::PACT_ATTACHMENT
      self.link_link          = pact_file
      id                      = if self.link_link =~ /^.*\/(.+)$/
                                  Regexp.last_match[1]
                                else
                                  self.link_link
                                end
      document                = Document.find_by(id: id) if (self.attachment_type ==
                                                             Constants::REVIEW_ATTACHMENT) &&
                                                            (pact_file =~ /^.*\/(\d+)$/)

      if document.present?
        self.link_description = document.name
        document.review_id    = self.review_id
        data_change           = DataChange.save_or_destroy_with_undo_session(document,
                                                                             'update',
                                                                             document.id,
                                                                             'documents',
                                                                             session_id)

        if data_change.present?
          session_id          = data_change.session_id 
        else
          okay                = false
          error               = "Can't update document: #{document.name}."
        end
      end
    elsif self.link_type == Constants::UPLOAD_ATTACHMENT && file.present?
      self.link_link          = file.original_filename
    elsif self.link_type == Constants::EXTERNAL_ATTACHMENT
      self.link_description   = if self.link_link =~ /^.*\/(.+)$/
                                  Regexp.last_match[1]
                                else
                                  self.link_link
                                end
    end

    if okay
      data_change             = DataChange.save_or_destroy_with_undo_session(self,
                                                                             self.id.present? ? 'update' : 'create',
                                                                             self.id,
                                                                             'review_attachments',
                                                                             session_id)

      if data_change.present?
        session_id            = data_change.session_id 
      else
        okay                  = false
        error                 = "Can't update review attachment: #{self.id}."
      end
    end

    if okay && file.present?
      okay                    = self.replace_file(file, session_id)
      error                   = "Can't attach #{file.original_filename}." if !okay
    end

    {
      status:     okay,
      error:      error,
      session_id: session_id
    }
  end
  
  def self.get_attachment_name(object)
    result          = ''
    attachment_type = object.try(:url_type)
    description     = object.try(:url_description)
    link            = object.try(:url_link)
    attachment_type = object.try(:link_type)        unless attachment_type.present?
    description     = object.try(:link_description) unless description.present?
    link            = object.try(:link_link)        unless link.present?

    return result unless attachment_type.present?

    case attachment_type
      when Constants::EXTERNAL_ATTACHMENT
        result      = if description.present?
                        description
                      else
                        if link =~ /^http[s]{0,1}:\/\/.+\/(.+)$/
                          result = Regexp.match(1)
                        else
                          link
                        end
                      end

      when Constants::PACT_ATTACHMENT
        id          = $1 if link =~ /^.*\/(\d+)$/
        document    = Document.find_by(id: id) if id.present?

        result      = if document.present?
                        document.name
                      elsif description.present?
                        description
                      else
                        link
                     end

      when Constants::UPLOAD_ATTACHMENT, Constants::INSTRUMENTS_ATTACHMENT
        file         = object.try(:file)
        file         = object.try(:upload_file) unless file.present?
        file_path    = object.try(:file_path)
        result       = if file.present?  &&
                          file.attached? &&
                          file.filename.present?
                         result = file.filename.to_s
                       elsif file_path.present?
                         result = File.basename(file_path)
                       else
                         description
                       end
      else
        result       = description if description.present?
    end

    return result
  end

  def self.get_attachment_url(object, type = 'download')
    result          = ''
    attachment_type = object.try(:url_type)
    link            = object.try(:url_link)
    attachment_type = object.try(:link_type)        unless attachment_type.present?
    link            = object.try(:link_link)        unless link.present?

    return result unless attachment_type.present?

    case attachment_type
      when Constants::EXTERNAL_ATTACHMENT
        result      = link

      when Constants::PACT_ATTACHMENT
        result      = link

        if type == 'download'
          id        = $1 if link =~ /^.*\/(\d+)$/
          result    = Rails.application.routes.url_helpers.item_document_download_document_path(object.item_id, id) if id.present?
        else
          id        = $1 if link =~ /^.*\/(\d+)$/
          result    = Rails.application.routes.url_helpers.item_document_display_path(object.item_id, id) if id.present?
        end

      when Constants::UPLOAD_ATTACHMENT, Constants::INSTRUMENTS_ATTACHMENT
        case object.class.name
          when 'SourceCode'
            if type == 'download'
              result = Rails.application.routes.url_helpers.item_source_code_download_path(object.item_id, object.id)
            else
              result = Rails.application.routes.url_helpers.item_source_code_display_path(object.item_id, object.id)
            end

          when 'ReviewAttachment'
            if type == 'download'
              result = Rails.application.routes.url_helpers.review_review_attachment_download_path(object.review_id, object.id)
            else
              result = Rails.application.routes.url_helpers.review_review_attachment_display_path(object.review_id, object.id)
            end

          when 'ModelFile'
            if type == 'download'
              result = Rails.application.routes.url_helpers.item_model_file_download_path(object.item_id, object.id)
            else
              result = Rails.application.routes.url_helpers.item_model_file_display_path(object.item_id, object.id)
            end

          when 'TestProcedure'
            if type == 'download'
              result = Rails.application.routes.url_helpers.item_test_proceedure_download_path(object.item_id, object.id)
            else
              result = Rails.application.routes.url_helpers.item_test_proceedure_display_path(object.item_id, object.id)
            end
        end
    end

    logger.info result

    if result =~ /^.*\/\/.*$/
      result = ''
    end

    return result
  end
end
