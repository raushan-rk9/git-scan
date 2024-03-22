#!/usr/bin/env ruby
user                          = User.find_by(email: 'paul@patmos-eng.com')
User.current                  = user
User.current.organization     = 'cies'
session_id                    = nil
old_files                     = SourceCode.where("organization='cies' AND codeid <= 72")
new_files                     = SourceCode.where("organization='cies' AND codeid > 72")
old_source_codes              = old_files.to_a.delete_if{|sc| !sc.function.present?}
new_source_codes              = new_files.to_a

old_source_codes.each do |old_source_code|
  next unless old_source_code.present?

  old_function                = ActionView::Base.full_sanitizer.sanitize(old_source_code.function).gsub(/ {/, '')
 
  next unless old_function.present?

  new_source_codes.each do |new_source_code|
    next unless new_source_code.file_name == old_source_code.file_name

    puts "#{old_source_code.file_name}, #{new_source_code.file_name}, #{old_function}"
  
    new_source_code.function           = old_function
    new_source_code.full_id            = old_source_code.full_id unless new_source_code.full_id.present?
    new_source_code.external_version   = old_source_code.external_version unless new_source_code.external_version.present?
    new_source_code.version            = old_source_code.version + 1
    data_change                        = DataChange.save_or_destroy_with_undo_session(new_source_code,
                                                                             'update',
                                                                             new_source_code.id,
                                                                             'source_codes',
                                                                             session_id)
    session_id                = data_change.session_id if data_change.present?
  end
end

old_files                     = SourceCode.where("organization='cies' AND codeid <= 72")
old_source_codes              = old_files.to_a.delete_if{|sc| !sc.module.present?}

old_source_codes.each do |old_source_code|
  next unless old_source_code.present?

  new_source_codes.each do |new_source_code|
    next unless new_source_code.file_name == old_source_code.file_name

    new_source_code.module                          = ''
    new_source_code.module_description_associations = ''

    old_source_code.module_descriptions.each do |module_description|
      new_source_code.module                          += ', ' if new_source_code.module.present?
      new_source_code.module                          += module_description.full_id
      new_source_code.module_description_associations += ', ' if new_source_code.module_description_associations.present?
      new_source_code.module_description_associations += module_description.id.to_s
    end
    new_source_code.module.gsub(/^ ,/, '')

    data_change             = DataChange.save_or_destroy_with_undo_session(new_source_code,
                                                                           'update',
                                                                            new_source_code.id,
                                                                            'source_codes',
                                                                            session_id)
    session_id                = data_change.session_id if data_change.present?

    next unless Associations.build_associations(new_source_code)

    data_change               = DataChange.save_or_destroy_with_undo_session(new_source_code,
                                                                             'update',
                                                                             new_source_code.id,
                                                                             'source_codes',
                                                                             session_id)
    session_id                = data_change.session_id if data_change.present?
  end
end
