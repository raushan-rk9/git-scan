user                          = User.find_by(email: 'paul@patmos-eng.com')
User.current                  = user
archive                      = Archive.new()
documents                     = Document.all
archive.archive_type          = Constants::DOCUMENT_ARCHIVE
session_id                    = nil
documents_with_attachments    = []
documents_without_attachments = []

documents.each do |document|
  if document.document_attachment.nil? || document.document_attachment.empty?
    documents_without_attachments.push(document)
  else
    documents_with_attachments.push(document)
  end
end

documents_with_attachments.each do |document|
  puts "Converting #{document.name} to a Folder."

  project_id           = document.project_id
  item_id              = document.item_id
  folder               = document.dup
  folder.id            = nil
  folder.item_id       = item_id
  folder.project_id    = project_id
  folder.document_type = Constants::FOLDER_TYPE
  data_change          = DataChange.save_or_destroy_with_undo_session(folder,
                                                                      'create',
                                                                      nil,
                                                                      'documents',
                                                                      session_id)
  session_id           = data_change.session_id if data_change.present?

  archive.clone_document_comments(project_id, item_id, document.id, folder.id,
                                   session_id)

  document.document_attachment.each do |attachment|
    next unless attachment.file.attached?

    file                       = attachment.file
    new_document               = document.dup
    new_document.id            = nil
    new_document.docid         = file.filename
    new_document.name          = file.filename
    new_document.parent_id     = folder.id
    new_document.item_id       = item_id
    new_document.project_id    = project_id
    new_document.document_type = 'Other'
    new_document.file_type     = file.content_type

    puts "Adding #{file.filename} to #{folder.name}."
    DataChange.save_or_destroy_with_undo_session(new_document,
                                                 'create',
                                                 nil,
                                                 'documents',
                                                 session_id)

    begin
      new_document.store_file(file)
      attachment.destroy
    rescue => e
      unless e.instance_of?(Errno::ENOENT)
        raise e
      end
    end
  end
  
  document.destroy
end
