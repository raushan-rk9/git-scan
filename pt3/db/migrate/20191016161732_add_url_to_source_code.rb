class AddUrlToSourceCode < ActiveRecord::Migration[5.2]
  def up
    add_column :source_codes, :url_type,        :text unless SourceCode.column_names.include?('url_type')
    add_column :source_codes, :url_description, :text unless SourceCode.column_names.include?('url_description')
    add_column :source_codes, :url_link,        :text unless SourceCode.column_names.include?('url_link')
  end

  def down
    remove_column :source_codes, :url_type            if SourceCode.column_names.include?('url_type')
    remove_column :source_codes, :url_description     if SourceCode.column_names.include?('url_description')
    remove_column :source_codes, :url_link            if SourceCode.column_names.include?('url_link')
  end
end
