class TemplateDocument < OrganizationRecord
  belongs_to :template
  validates  :template_id, presence: true

  # Files
  has_one_attached :file, dependent: false

  # Validate only size. Do not validate if file is not attached.
  validates :file, file_size: { less_than_or_equal_to: 200.megabytes }, if: proc { file.attached? }

  attr_accessor :new_document_name

  def duplicate_document(new_title = nil, new_dal = nil)
    new_title                   = title if new_title.nil?
    new_dal                     = dal   if new_dal.nil?
    template_file               = file  if file.attached?
    new_document                = TemplateDocument.new()
    new_document.title          = new_title
    new_document.dal            = new_dal
    new_document.description    = description
    new_document.notes          = notes
    new_document.docid          = docid
    new_document.name           = name
    new_document.category       = category
    new_document.document_type  = document_type
    new_document.document_class = document_class
    new_document.file_type      = file_type
    new_document.template_id    = template_id
    new_document.organization   = organization
    pg_results                  = ActiveRecord::Base.connection.execute("SELECT nextval('template_documents_id_seq')")

    pg_results.each { |row| new_document.document_id = row["nextval"] } if pg_results.present?

    result                      = DataChange.save_or_destroy_with_undo_session(new_document,
                                                                               'create',
                                                                               nil,
                                                                               'template_documents')

    if result.present? && template_file.present?
      begin
        new_document.file.attach(io:           StringIO.new(file.download),
                                 filename:     file.filename,
                                 content_type: file.content_type)
      rescue Errno::EACCES
        new_document.file.attach(io:           StringIO.new(file.download),
                                 filename:     file.filename,
                                 content_type: file.content_type)
      end

      DataChange.save_or_destroy_with_undo_session(new_document,
                                                   'update',
                                                   new_document.id,
                                                   'template_documents',
                                                   result.session_id)
    end

    return result
  end
end
