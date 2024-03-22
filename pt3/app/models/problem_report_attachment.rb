class ProblemReportAttachment < OrganizationRecord
  belongs_to :problem_report,   optional: true
  belongs_to :item,             optional: true
  belongs_to :project,          optional: true

  # Validations
  validates :problem_report_id, presence: true
  validates :project_id,        presence: true
  validates :user,              presence: true

  # Files
  has_one_attached :file,       dependent: false

  # Validate only size. Do not validate if file is not attached.
  validates :file,              file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { file.attached? }

  # Accessors
  attr_accessor :pact_file

  @@problem_report_attachments_path     = nil

  def get_root_path
    path   = ''

    unless @@problem_report_attachments_path.present?
      local                             = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root                              = local['root']                        if local.present?
      @@problem_report_attachments_path = File.join(root,
                                                    'problem_report_attachments',
                                                    User.current.organization) if root.present?
    end

    path                                = @@problem_report_attachments_path
  end

  def get_file_path
    get_root_path
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

  def store_file(attachment_file, session_id = nil)
    filename         = nil
    directory        = get_root_path
    self.upload_date = DateTime.now

    FileUtils.mkpath(directory) unless Dir.exist?(directory)

    if attachment_file.present?
      if attachment_file.instance_of?(ActiveStorage::Attached::One)
        filename     = File.join(directory, attachment_file.filename)

        self.file.attach(io: attachment_file)
        File.open(filename, 'wb') { |f| f.write(attachment_file.download) }
      else
        filename     = File.join(directory, attachment_file.original_filename)

        attachment_file.tempfile.rewind
        self.file.attach(io:           attachment_file.tempfile,
                         filename:     attachment_file.original_filename,
                         content_type: attachment_file.content_type)
        attachment_file.tempfile.rewind
        File.open(filename, 'wb') { |f| f.write(attachment_file.tempfile.read) }
      end
    else
      nil
    end

    if self.id.present?
      DataChange.save_or_destroy_with_undo_session(self,
                                                   'update',
                                                   self.id,
                                                   'problem_report_attachments',
                                                   session_id)
    else
      DataChange.save_or_destroy_with_undo_session(self,
                                                   'create',
                                                   self.id,
                                                   'problem_report_attachments',
                                                   session_id)
    end

    return filename
  end

  def replace_file(attachment_file, project_id, item_id, problem_report_id, session_id = nil)
    archive                    = Archive.new()
    title                      = "Update of #{I18n.t('problemreports.attachment')} "       \
                                 "for #{ProblemReport.get_full_title(problem_report_id)}."
    archive.name,              = title
    archive.full_id,           = title
    archive.description        = title
    archive.revision           = "1"
    archive.version            = "1"
    archive.archive_type       = Constants::PROBLEM_REPORT_CHANGE
    archive.project_id         = project_id
    archive.item_id            = item_id
    archive.archive_project_id = project_id
    archive.archive_item_id    = item_id
    archive.archived_at        = DateTime.now()
    archive.organization       = User.current.organization
    data_change                = DataChange.save_or_destroy_with_undo_session(archive,
                                                                              'create',
                                                                              nil,
                                                                              'archives',
                                                                              session_id)
    session_id                 = data_change.session_id if data_change.present?

    archive.clone_problem_report_attachment(self, self.project_id, self.item_id,
                                            problem_report_id, session_id)
    self.store_file(attachment_file)
    attachment_file.tempfile.rewind

    begin
      self.file.attach(io:           attachment_file.tempfile,
                       filename:     attachment_file.original_filename,
                       content_type: attachment_file.content_type)
    rescue Errno::EACCES
      self.file.attach(io:           attachment_file.tempfile,
                       filename:     attachment_file.original_filename,
                       content_type: attachment_file.content_type)
    end

    DataChange.save_or_destroy_with_undo_session(self,
                                                 'update',
                                                 self.id,
                                                 'problem_report_attachments',
                                                 session_id)
  end
end
