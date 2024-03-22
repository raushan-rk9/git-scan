module ApplicationHelper

  def get_title_from_controller
    name                 = controller.controller_name
    action               = controller.action_name
    action_set           = false
    name_set             = false

    case(action)
      when 'index'
        action           = 'List'

        case(name)
          when 'problem_report_histories'
            action       = sanitize(@problem_report.title) if @problem_report.present?
            action_set   = true
        end
      when 'document_history'
        name             = 'Document History'
        name_set         = true
        action           = sanitize(@document.name) if @document.present?
        action_set       = true
      when 'show', 'edit'
        case(name)
          when 'action_items'
            action       = sanitize(@project.description) if @project.present?
            action_set   = true
          when 'archives'
            action       = sanitize(@archive.description) if @archive.present?
            action_set   = true
          when 'checklist_items'
            action       = sanitize(@checklist_item.description) if @checklist_item.present?
            action_set   = true
          when 'code_checkmarks'
            action       = sanitize(@code_checkmark.checkmark_id) if @code_checkmark.present?
            action_set   = true
          when 'document_types'
            action       = sanitize(@document_type.description) if @document_type.present?
            action_set   = true
          when 'documents', 'document_attachments'
            action       = sanitize(@document.name) if @document.present?
            action_set   = true
          when 'high_level_requirements'
            action       = sanitize(@high_level_requirement.full_id) if @high_level_requirement.present?
            action_set   = true
          when 'items'
            action       =  sanitize(@item.name) if @item.present?
            action_set   = true
          when 'low_level_requirements'
            action       = sanitize(@low_level_requirement.full_id) if @low_level_requirement.present?
            action_set   = true
          when 'projects'
            action       = sanitize(@project.name) if @project.present?
            action_set   = true
          when 'problem_report_attachments'
            if @problem_report_attachment.try(:link_description)
              action     = sanitize(@problem_report_attachment.link_description)
              action_set = true
            end
          when 'problem_reports', 'problem_report_histories'
            action       = sanitize(@problem_report.title) if @problem_report.present?
            action_set   = true
          when 'reviews', 'review_attachments'
            action       = sanitize(@review.title) if @review.present?
            action_set   = true
          when 'model_files'
            action       = sanitize(@model_file.full_id) if @model_file.present?
            action_set   = true
          when 'module_descriptions'
            action       = sanitize(@module_description.full_id) if @module_description.present?
            action_set   = true
          when 'source_codes'
            action       = sanitize(@source_code.full_id) if @source_code.present?
            action_set   = true
          when 'system_requirements'
            action       = sanitize(@system_requirement.full_id) if @system_requirement.present?
            action_set   = true
          when 'test_cases'
            action       = sanitize(@test_case.full_id) if @test_case.present?
            action_set   = true
          when 'test_procedures'
            action       = sanitize(@test_procedures.full_id) if @test_procedures.present?
            action_set   = true
          when 'template_checklist_items'
            action       = sanitize(@template_checklist_item.description) if @template_checklist_item.present?
            action_set   = true
          when 'template_checklists'
            action       = sanitize(@template_checklist.title) if @template_checklist.present?
            action_set   = true
          when 'template_documents'
            action       = sanitize(@template_document.title) if @template_document.present?
            action_set   = true
          when 'templates'
            action       = sanitize(@template.title) if @template.present?
            action_set   = true
          when 'users'
            action       = sanitize(@user.fullname) if @user.present?
            action_set   = true
        end
    end

    case(name)
      when 'high_level_requirements'
        name             = Item.item_type_title(@item, :high_level)
        name_set         = true
      when 'low_level_requirements'
        name             = Item.item_type_title(@item, :low_level)
        name_set         = true
    end

    action               = action.titleize unless action_set
    name                 = name.titleize unless name_set
    name                 = name.sub(/s$/, '') if name == "Source Codes"
    result               = "#{name.titleize}: #{action}"

    return result
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = ENV.fetch("SYSACR") { "CMS" }
    if page_title.empty?
      get_title_from_controller + " | " + base_title
    else
      page_title + " | " + base_title
    end
  end

  # Render an icon for a boolean variable.
  def checkicon(boolean)
    if boolean == true
      icon('far', 'check-square')
    else
      icon('far', 'square')
    end
  end

  # Render an icon for a boolean variable.
  def display_full_id(hardware_software_item, current_item)
    return unless hardware_software_item.present?

    item = if defined?(hardware_software_item.item_id) &&
              hardware_software_item.item_id.present?
             Item.find_by(id: hardware_software_item.item_id)
           end

    if hardware_software_item.respond_to?(:fullreqid)
      if item != current_item
        if item.present?
          "(#{item.name}): #{hardware_software_item.fullreqid}"
        else
          hardware_software_item.fullreqid
        end
      else
        hardware_software_item.fullreqid
      end
    elsif hardware_software_item.respond_to?(:fullcaseid)
      if item != current_item
        if item.present?
          "(#{item.name}): #{hardware_software_item.fullcaseid}"
        else
          hardware_software_item.fullcaseid
        end
      else
        hardware_software_item.fullcaseid
      end
    elsif hardware_software_item.respond_to?(:fullcodeid)
      if item != current_item
        if item.present?
          "(#{item.name}): #{hardware_software_item.fullcodeid}"
        else
          hardware_software_item.fullcodeid
        end
      else
        hardware_software_item.fullcodeid
      end
    elsif defined?(hardware_software_item.full_id)
      if item != current_item
        if item.present?
          "(#{item.name}): #{hardware_software_item.full_id}"
        else
          hardware_software_item.full_id
        end
      else
        hardware_software_item.full_id
      end
    else
      ""
    end
  end
end
