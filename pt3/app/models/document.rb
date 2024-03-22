class Document < OrganizationRecord
  belongs_to :item,    optional: true
  belongs_to :project, optional: true
  belongs_to :review,  optional: true
  belongs_to :parent,  optional: true

#  has_one    :parent, class_name: :document, :foreign_key => "id"
  # Access document comments from documents
  has_many :document_comment, inverse_of: :document, dependent: :destroy
  accepts_nested_attributes_for :document_comment, allow_destroy: true
  # Access file attachments from documents
  has_many :document_attachment, inverse_of: :document, dependent: :destroy
  accepts_nested_attributes_for :document_attachment, allow_destroy: true
  # Files
  has_one_attached :file, dependent: false
  # Validate only size. Do not validate if file is not attached.
  validates :file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { file.attached? }
  # Validations
  validates :docid,       presence: true, allow_blank: false
  validates :project_id,  presence: true, allow_blank: false
  validates :item_id,     presence: true, allow_blank: false
  validates :name,        presence: true, allow_blank: false

  # Instantiate variables not in database
  attr_accessor :selected
  attr_accessor :release_document
  attr_accessor :session_id

  @@documents_path = nil;

  def self.id_from_docid(id)
    result     = nil

    return result unless id.present?

    document = if id.kind_of?(Integer)
                 self.find_by(id: id)
               elsif id =~ /^\d+\.*\d*$/
                 self.find_by(id: id.to_i)
               else
                 self.find_by(docid: id)
               end
    result   = document.id if document.present?

    return result
  end

  def self.id_from_name(id)
    result     = nil

    return result unless id.present?

    document = if id.kind_of?(Integer)
                 self.find_by(id: id)
               elsif id =~ /^\d+\.*\d*$/
                 self.find_by(id: id.to_i)
               else
                 self.find_by(name: id)
               end
    result   = document.docid if document.present?

    return result
  end

  def self.docid_from_id(id)
    result   = ''
    document = self.find_by(id: id) if id.present?
    result   = document.docid       if document.present?

    return result
  end

  def self.name_from_id(id)
    result   = ''
    document = self.find_by(id: id) if id.present?
    result   = document.name       if document.present?

    return result
  end

  def self.item_name_and_name_from_id(id)
    result   = ''

    document = self.find_by(id: id) if id.present?

    return result unless document.present?

    result   = document.item.name + ' : ' + document.name

    return result
  end

  def get_tree
    tree = []

    if !parent_id.nil?
      document = Document.find(parent_id)

      tree.push(document.get_tree)
    end

    if document_type == Constants::FOLDER_TYPE
      tree.push(name)
    end

    if tree.empty?
      ''
    else
      tree.join('/')
    end
  end

  def get_file_path
    path   = ''

    unless @@documents_path.present?
      local            = YAML.load_file("#{Rails.root.to_s}/config/storage.yml")['local']
      root             = local['root']                if local.present?
      @@documents_path = File.join(root, 'documents', User.current.organization) if root.present?
    end

    if @@documents_path.present?
      if file_path.present?
        path = File.join(@@documents_path, get_tree, File.basename(file_path))
      else
        path = File.join(@@documents_path, get_tree)
      end
    end
  end

  def get_file_contents
    filename = if self.file_path.present? && File.exist?(self.file_path)
                 self.file_path
               else
                 get_file_path
               end

    if filename.present? && File.exist?(filename) && File.ftype(filename) == 'file'
      File.open(filename, 'rb') { |f| f.read }
    else
      nil
    end
  end

  def store_file(file, add_version = false, increment_version = false)
    if file.instance_of?(ActiveStorage::Attached::One)
      self.file_path = file.filename
    else
      return unless file.tempfile.present?

      self.file_path = file.original_filename
    end

    if add_version
      if increment_version
        self.version = if self.version.present?
                         self.version + 1
                       else
                         1
                       end
      end

      if self.file_path =~ /^(.+)\-(\d)(\..+)$/
        self.file_path = Regexp.last_match[1] + "-#{self.version}" +  Regexp.last_match[3]
      elsif self.file_path =~ /^(.+)(\..+)$/
        self.file_path = Regexp.last_match[1] + "-#{self.version}" +  Regexp.last_match[2]
      else
        self.file_path = "-#{self.version}"
      end
    end

    filename         = get_file_path
    directory        = File.dirname(filename)
    self.upload_date = DateTime.now

    unless Dir.exist?(directory)
      FileUtils.mkpath(directory)
    end

    if filename.present?
      if file.instance_of?(ActiveStorage::Attached::One)
        File.open(filename, 'wb') { |f| f.write(file.download) }
      else
        file.tempfile.rewind
        File.open(filename, 'wb') { |f| f.write(file.tempfile.read) }

        self.file_type = file.content_type
      end

      self.file_path   = filename
    else
      nil
    end
  end

  def replace_file(file, project_id, item_id, session_id = nil)
    archive                    = Archive.new()
    title                      = "Update of Document ID: #{self.docid}, " \
                                 "Version #{self.version}."
    archive.name,              = title
    archive.full_id,           = title
    archive.description        = title
    archive.revision           = "1"
    archive.version            = "1"
    archive.project_id         = project_id
    archive.item_id            = item_id
    archive.archive_project_id = project_id
    archive.archive_item_id    = item_id
    archive.archive_type       = Constants::DOCUMENT_CHANGE
    archive.archived_at        = DateTime.now()
    archive.organization       = User.current.organization
    data_change                = DataChange.save_or_destroy_with_undo_session(archive,
                                                                              'create',
                                                                              nil,
                                                                              'archives',
                                                                              session_id)
    session_id                 = data_change.session_id if data_change.present?

    archive.clone_document(self, self.project_id, self.item_id, session_id)
    self.store_file(file, true, true)
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

    DataChange.save_or_destroy_with_undo_session(self,
                                                 'update',
                                                 self.id,
                                                 'documents',
                                                 session_id)
  end

  def self.get_or_create_folder(folder_name,
                                project_id = nil,
                                item_id    = nil,
                                parent_id  = nil,
                                session_id = nil)
    folder                 = nil

    if item_id.present? && project_id.present?
      folder               = Document.find_by(document_type: Constants::FOLDER_TYPE,
                                              name:          folder_name,
                                              item_id:       item_id,
                                              project_id:    project_id,
                                              organization:  User.current.organization)
    elsif item_id.present?
      folder               = Document.find_by(document_type: Constants::FOLDER_TYPE,
                                              name:          folder_name,
                                              item_id:       item_id,
                                              organization:  User.current.organization)
    else
      folder               = Document.find_by(document_type: Constants::FOLDER_TYPE,
                                              name:          folder_name,
                                              organization:  User.current.organization)
    end

    unless folder.present?
      folder               = Document.new
      folder.name          = folder_name
      folder.document_type = Constants::FOLDER_TYPE
      folder.parent_id     = parent_id
      folder.docid         = folder_name
      folder.project_id    = project_id
      folder.item_id       = item_id
      pg_results           = ActiveRecord::Base.connection.execute("SELECT nextval('documents_document_id_seq')")

      pg_results.each { |row| folder.document_id = row["nextval"] } if pg_results.present?

      change_session       = DataChange.save_or_destroy_with_undo_session(folder,
                                                                          'create',
                                                                          nil,
                                                                          'documents',
                                                                          session_id)

      if change_session.present?
        session_id         = change_session.session_id
      end
    end

    return folder
  end

  def self.duplicate_file(folder,
                          filename,
                          file_object,
                          use_link = false,
                          use_file = false)
    logger.info("Duplicating: #{filename}")

    url_type          = nil
    url_link          = nil
    file              = nil
    path              = folder.get_file_path
    file_path         = File.join(path, filename)

    if use_link
      url_type        = file_object.link_type
      url_link        = file_object.link_link
    else
      url_type        = file_object.url_type
      url_link        = file_object.url_link
    end

    if use_file
      file            = file_object.file        if file_object.file.attached?
    else
      file            = file_object.upload_file if file_object.upload_file.attached?
    end

    FileUtils.mkpath(path) unless Dir.exist?(path)

    if url_type == 'ATTACHMENT'
      if file.present?
        if File.readable?(file_path)
          File.open(file_path, 'wb') { |f| f.write(file.download) }
        else
          logger.error("No Attachment File Present: #{filename} File Path: #{file_path}")

          file_path     = nil
        end
      else
        file_path     = nil

        logger.error("No File Present: #{filename}")
      end
    elsif url_type == 'PACT'
      document        = nil

      if url_link =~ /.*\/(\d+)$/
        document      = Document.find(Regexp.last_match[1])
      end

      if document.present?
        File.open(file_path, 'wb') { |f| f.write(document.get_file_contents) }
      else
        logger.error("No Document Present: #{filename} File Path: #{file_path}")

        file_path     = nil
      end
    elsif url_type == 'EXTERNAL'
      download_link   = nil

      if url_link =~ /^https:\/\/gitlab.faaconsultants.com\/.*$/
        gitlab_access = GitlabAccess.find_by(user_id: User.current.id)

        if gitlab_access.present? && gitlab_access.token.present?
          download_link = url_link.gsub('/blob/', '/raw/') + '?inline=false&private_token=' + gitlab_access.token
        end

        if download_link.present?
          uri           = URI.parse(download_link)
          http          = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl  = true
          response      = http.get(uri.request_uri)
  
          File.open(file_path, 'wb') { |f| f.write(response.body) }
        else
          unless File.exists?(file_path)
            file_path     = nil
  
            logger.error("No download_link Present: #{filename}")
          end

          return file_path
        end
      end

      if url_link =~ /^https:\/\/github.com\/.*\/blob\/(.*)$/
        filename      = Regexp.last_match(1)
        github_access = GithubAccess.get_github_access

        if github_access.present? && github_access.token.present? && filename.present?
          access_path = if url_link =~ /^.*main\/(.*)/
                            Regexp.last_match(1)
                        elsif url_link =~ /^.*\/(.*\/.*$)/
                            Regexp.last_match(1)
                        end
          contents    = github_access.get_file_contents(access_path) if access_path.present?     

          if contents.present?
            File.open(file_path, 'wb') { |f| f.write(contents) }
          else
            logger.error("Can't download file:: #{filename}")
          end
        else
          unless File.exists?(file_path)
            file_path     = nil
  
            logger.error("No download_link Present: #{filename}")
          end

          return file_path
        end
      end

      return file_path
    end

    if file_path.present?
      logger.info("Successfully Duplicated: #{filename}: #{file_path}")
    end

    return file_path
  end

  def self.add_document(file,
                        project_id,
                        item_id,
                        category      = 'Other',
                        document_type = 'Other',
                        session_id    = nil,
                        folder_name   = nil)
    filename                  = if file.try(:original_filename)
                                  file.original_filename
                                elsif file.try(:filename)
                                  file.filename
                                elsif file.try(:name)
                                  file.name
                                else
                                  ''
                                end
    folder                    = if folder_name.present?
                                  Document.get_or_create_folder(folder_name,
                                                                project_id,
                                                                item_id,
                                                                nil,
                                                                session_id)
                                else
                                  nil
                                end
      session_id              = folder.session_id if folder.present?
      document                = Document.new()
      document.docid          = File.basename(filename)
      document.name           = File.basename(filename)
      document.category       = category
      document.document_type  = document_type
      document.file_type      = file.content_type
      document.file_path      = filename
      document.parent_id      = folder.try(:id)
      document.item_id        = item_id
      document.project_id     = project_id
      data_change             = DataChange.save_or_destroy_with_undo_session(document,
                                                                             'create',
                                                                             nil,
                                                                             'documents',
                                                                             session_id)
      session_id              = data_change.session_id if data_change.present?

      document.store_file(file)
      file.tempfile.rewind

      begin
        document.file.attach(io:           file.tempfile,
                             filename:     file.original_filename,
                             content_type: file.content_type)
      rescue Errno::EACCES
        document.file.attach(io:           file.tempfile,
                             filename:     file.original_filename,
                             content_type: file.content_type)
      end


      DataChange.save_or_destroy_with_undo_session(document,
                                                   'update',
                                                   document.id,
                                                   'documents',
                                                   session_id)

      return document
  end

  def self.replace_document_file(document_id, file, session_id = nil)
    id       = if document_id =~ /^\d+$/
                 document_id.to_i
               elsif document_id.kind_of?(Integer)
                 document_id
               end

    return unless id.present?

    document = Document.find(id)

    document.replace_file(file, document.project_id, document.item_id,
                          session_id)

    return document
  end

  def update_version(session_id = nil)
  end

  def release_revision(session_id = nil)
  end
end
