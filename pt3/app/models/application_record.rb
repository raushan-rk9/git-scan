class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def clean_filename(filename)
    filename.gsub!(/[\x00\/\\:\*\?\"<>\|\~\ \`]/, '-') if filename.present?

    filename
  end
end

ActiveStorage::Blob::ClassMethods.module_eval do
  def build_after_upload(io:, filename:, content_type: nil, metadata: nil)
    new.tap do |blob|
      filename.gsub!(/[\x00\/\\:\*\?\"<>\|\~\ \`]/, '-') if filename.present?

      blob.filename     = filename
      blob.content_type = content_type
      blob.metadata     = metadata

      blob.upload io
    end
  end
end
