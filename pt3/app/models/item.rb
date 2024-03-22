class Item < OrganizationRecord
  belongs_to :project,                    optional: true

  # Associations
  has_many   :high_level_requirements,    dependent: :destroy
  has_many   :low_level_requirements,     dependent: :destroy
  has_many   :source_codes,               dependent: :destroy
  has_many   :test_cases,                 dependent: :destroy
  has_many   :test_procedures,            dependent: :destroy
  has_many   :documents,                  dependent: :destroy
  has_many   :reviews,                    dependent: :destroy
  has_many   :problem_reports,            dependent: :destroy
  has_many   :problem_report_attachments, dependent: :destroy
  has_many   :model_files,                dependent: :destroy
  has_many   :module_descriptions,        dependent: :destroy

  # Validations
  validates  :project_id,                 presence: true, allow_blank: false
  validates  :name,                       presence: true, allow_blank: false
  validates  :identifier,                 presence: true, allow_blank: false

  AssuranceLevels = ['A', 'B', 'C', 'D', 'E', '1', '2', '3', '4', 'Other']

public
  # Generate Item Long ID, identifier + name
  def long_id
    return self.identifier + ':' + self.name
  end

  def self.identifier_from_id(id)
    result = ''
    item   = Item.find_by(id: id) if id.present?
    result = item.identifier      if item.present?

    return result
  end

  def self.id_from_identifier(identifier,
                              organization = User.current.organization)
    result  = nil

    return result unless identifier.present?

    result  = if identifier =~ /^\d+\.*\d*$/
                identifier.to_i
              else
                item = Item.find_by(identifier:   identifier,
                                    organization: organization) 

                if item.present?
                  item.id
                else
                  nil
                end
              end

    return result
  end

  def duplicate_documents(session_id = nil)
    return unless self.itemtype.present?

    item_class           = Constants::ItemType[self.itemtype.to_i] if self.itemtype.present?
    templates            = Template.where(organization:   User.current.organization)
    session_id           = nil
    has_documents        = false

    templates.each do |template|
      has_documents = true if template.template_document.present?

      break if has_documents
    end

    return unless has_documents

    templates.each do |template|
      template.template_document.each do |template_document|
        next if (level.present?                               &&
                 template_document.dal.present?               && 
                 (template_document.dal            != level)) ||
                (item_class.present?                          &&
                 template_document.document_class.present?    && 
                 (template_document.document_class != item_class))

        result     = duplicate_document(template_document, session_id)
        session_id = result.session_id if result.present?
      end if template.template_document.present?
    end if templates.present?
  end

  def duplicate_document(template_document, session_id)
    file                        = template_document.file if template_document.file.attached?
    new_document                = Document.new()
    new_document.docid          = template_document.title
    new_document.name           = template_document.description
    new_document.docid          = file.filename unless new_document.docid.present?
    new_document.name           = file.filename unless new_document.name.present?
    new_document.category       = template_document.category
    new_document.document_type  = template_document.document_type
    new_document.file_type      = template_document.file_type
    new_document.revision       = template_document.revision
    new_document.draft_revision = template_document.draft_revision
    new_document.item_id        = self.id
    new_document.project_id     = self.project_id
    pg_results                  = ActiveRecord::Base.connection.execute("SELECT nextval('documents_document_id_seq')")

    pg_results.each { |row| new_document.document_id = row["nextval"] } if pg_results.present?

    result                      = DataChange.save_or_destroy_with_undo_session(new_document,
                                                                               'create',
                                                                               nil,
                                                                               'documents',
                                                                               session_id)

    if result.present? && file.present?
      new_document.store_file(file)
      DataChange.save_or_destroy_with_undo_session(new_document,
                                                   'update',
                                                   new_document.id,
                                                   'documents',
                                                   session_id)
    end

    return result
  end

  # Create csv
  def self.to_csv(project_id)
    # Get all system requirements
    sysreqs = SystemRequirement.where(project_id:   project_id,
                                      organization: User.current.organization).order(:full_id)

    begin
      sysreqs.sort() do |x, y|
        x_id = ''
        y_id = ''

        if x.full_id =~ /^.*\-(\d+)$/
          x_id = Regexp.last_match[1].to_i
        else
          x_id = x.full_id
        end

        if y.full_id =~ /^.*\-(\d+)$/
          y_id = Regexp.last_match[1].to_i
        else
          y_id = y.full_id
        end

        if x_id.present? && y_id.present?
          x_id <=> y_id
        else
          0
        end
      end
    rescue
    end

    unless sysreqs.empty?
      CSV.generate(headers: true) do |csv|
        sysreqs.each do |sysreq|
          rows        = []
          columns     = []
          sysreq_hlrs = sysreq.high_level_requirements.order(:full_id)

          if sysreq_hlrs.empty?
            columns.push(Sanitize.fragment(sysreq.fullreqid).gsub('&nbsp;', ' ').strip)
            columns.push(Sanitize.fragment(sysreq.description).gsub('&nbsp;', ' ').strip)
            rows.push(columns)
          else
            first_hlr = true

            sysreq_hlrs.each do |sysreq_hlr|
              if first_hlr
                first_hlr = false

                columns.push(Sanitize.fragment(sysreq.fullreqid).gsub('&nbsp;', ' ').strip)
                columns.push(Sanitize.fragment(sysreq.description).gsub('&nbsp;', ' ').strip)
                columns.push(Sanitize.fragment(sysreq_hlr.fullreqid).gsub('&nbsp;', ' ').strip)
                columns.push(Sanitize.fragment(sysreq_hlr.description).gsub('&nbsp;', ' ').strip)
              else
                columns = ['', '']

                columns.push(Sanitize.fragment(sysreq_hlr.fullreqid).gsub('&nbsp;', ' ').strip)
                columns.push(Sanitize.fragment(sysreq_hlr.description).gsub('&nbsp;', ' ').strip)
              end

              sysreq_hlr_llrs = sysreq_hlr.low_level_requirements.order(:full_id)

              if sysreq_hlr_llrs.empty?
                rows.push(columns)
              else
                first_llr = true

                sysreq_hlr_llrs.each do |sysreq_hlr_llr|
                  if first_llr
                    first_llr = false

                    columns.push(Sanitize.fragment(sysreq_hlr_llr.fullreqid).gsub('&nbsp;', ' ').strip)
                    columns.push(Sanitize.fragment(sysreq_hlr_llr.description).gsub('&nbsp;', ' ').strip)
                    rows.push(columns)
                  else
                    columns = ['', '', '', '']

                    columns.push(Sanitize.fragment(sysreq_hlr_llr.fullreqid).gsub('&nbsp;', ' ').strip)
                    columns.push(Sanitize.fragment(sysreq_hlr_llr.description).gsub('&nbsp;', ' ').strip)

                    if sysreq_hlr_llr.archive_id.present?
                      archive = Archive.find(sysreq_hlr_llr.archive_id)

                      columns.push(archive.revision)
                      columns.push(archive.version)
                    end

                    rows.push(columns)
                  end
                end
              end
            end
          end
  
          rows.each do |row|
            csv << row
          end
        end
      end
    end
  end

  def self.to_xls(project_id)
    xls_workbook  = Spreadsheet::Workbook.new
    xls_worksheet = xls_workbook.create_worksheet
    current_row   = 0

    # Get all system requirements
    sysreqs       = SystemRequirement.where(project_id:   project_id,
                                            organization: User.current.organization).order(:full_id)

    begin
    sysreqs.sort() do |x, y|
      x_id = ''
      y_id = ''

      if x.full_id =~ /^.*\-(\d+)$/
        x_id = Regexp.last_match[1].to_i
      else
        x_id = x.full_id
      end

      if y.full_id =~ /^.*\-(\d+)$/
        y_id = Regexp.last_match[1].to_i
      else
        y_id = y.full_id
      end

      if x_id.present? && y_id.present?
        x_id <=> y_id
      else
        0
      end
    end
    rescue
    end

    unless sysreqs.empty?
      sysreqs.each do |sysreq|
        rows        = []
        columns     = []
        sysreq_hlrs = sysreq.high_level_requirements.order(:full_id)

        if sysreq_hlrs.empty?
          columns.push(Sanitize.fragment(sysreq.fullreqid).gsub('&nbsp;', ' ').strip)
          columns.push(Sanitize.fragment(sysreq.description).gsub('&nbsp;', ' ').strip)
          rows.push(columns)
        else
          first_hlr = true

          sysreq_hlrs.each do |sysreq_hlr|
            if first_hlr
              first_hlr = false

              columns.push(Sanitize.fragment(sysreq.fullreqid).gsub('&nbsp;', ' ').strip)
              columns.push(Sanitize.fragment(sysreq.description).gsub('&nbsp;', ' ').strip)
              columns.push(Sanitize.fragment(sysreq_hlr.fullreqid).gsub('&nbsp;', ' ').strip)
              columns.push(Sanitize.fragment(sysreq_hlr.description).gsub('&nbsp;', ' ').strip)
            else
              columns = ['', '']

              columns.push(Sanitize.fragment(sysreq_hlr.fullreqid).gsub('&nbsp;', ' ').strip)
              columns.push(Sanitize.fragment(sysreq_hlr.description).gsub('&nbsp;', ' ').strip)
            end

            sysreq_hlr_llrs = sysreq_hlr.low_level_requirements.order(:full_id)

            if sysreq_hlr_llrs.empty?
              rows.push(columns)
            else
              first_llr = true

              sysreq_hlr_llrs.each do |sysreq_hlr_llr|
                if first_llr
                  first_llr = false

                  columns.push(Sanitize.fragment(sysreq_hlr_llr.fullreqid).gsub('&nbsp;', ' ').strip)
                  columns.push(Sanitize.fragment(sysreq_hlr_llr.description).gsub('&nbsp;', ' ').strip)

                  if sysreq_hlr_llr.archive_id.present?
                    archive = Archive.find(sysreq_hlr_llr.archive_id)

                    columns.push(archive.revision)
                    columns.push(archive.version)
                  end

                  rows.push(columns)
                else
                  columns = ['', '', '', '']

                  columns.push(Sanitize.fragment(sysreq_hlr_llr.fullreqid).gsub('&nbsp;', ' ').strip)
                  columns.push(Sanitize.fragment(sysreq_hlr_llr.description).gsub('&nbsp;', ' ').strip)

                  if sysreq_hlr_llr.archive_id.present?
                    archive = Archive.find(sysreq_hlr_llr.archive_id)

                    columns.push(archive.revision)
                    columns.push(archive.version)
                  end
                  rows.push(columns)
                end
              end
            end
          end
  
          rows.each do |row|
            xls_worksheet.insert_row(current_row, row)

            current_row += 1
          end
        end
      end
    end

    file = Tempfile.new('system-requirements')

    xls_workbook.write(file.path)
    file.rewind

    result = file.read

    file.close
    file.unlink

    return result
  end

  def get_item_title(requirement_type = :high_level,
                     title_type       = :plural)
    result         = ''

    if itemtype == '2'
      if requirement_type == :low_level
        case title_type
          when :singular
            result = I18n.t('misc.design')
          when :singular_shortened
            result = I18n.t('requirements.design_id')
          when :plural
            result = I18n.t('misc.design')
          when :type
            result = I18n.t('misc.design')
          when :plural_shortened
            result = I18n.t('requirements.design_ids')
        end
      elsif requirement_type == :module_description
        case title_type
          when :singular, :singular_shortened
            result = I18n.t('module_description.single_title')
          when :singular_shortened
            result = I18n.t('module_description.module_description_id')
          when :plural
            result = I18n.t('module_description.pl_title')
          when :type
            result = I18n.t('module_description.single_title')
          when :plural_shortened
            result = I18n.t('module_description.pl_title')
        end
      else
        case title_type
          when :singular
            result = I18n.t('misc.requirement')
          when :singular_shortened
            result = I18n.t('requirements.id')
          when :plural
            result = I18n.t('misc.requirements')
          when :type
            result = I18n.t('misc.requirement')
          when :plural_shortened
            result = I18n.t('requirements.ids')
        end
      end
    else
      if requirement_type == :low_level
        case title_type
          when :singular
            result = I18n.t('misc.low_level_requirement')
          when :singular_shortened
            result = I18n.t('requirements.id')
          when :plural
            result = I18n.t('misc.low_level_requirements')
          when :type
            result = I18n.t('misc.low_level')
          when :plural_shortened
            result = I18n.t('requirements.ids')
        end
      else
        if requirement_type == :module_description
          case title_type
            when :singular, :singular_shortened
              result = I18n.t('module_description.single_title')
            when :singular_shortened
              result = I18n.t('module_description.module_description_id')
            when :plural
              result = I18n.t('module_description.pl_title')
            when :type
              result = I18n.t('module_description.single_title')
            when :plural_shortened
              result = I18n.t('module_description.pl_title')
          end
        else
          case title_type
            when :singular
              result = I18n.t('misc.high_level_requirement')
            when :singular_shortened
              result = I18n.t('requirements.id')
            when :plural
              result = I18n.t('misc.high_level_requirements')
            when :type
              result = I18n.t('misc.high_level')
            when :plural_shortened
              result = I18n.t('misc.high_level_requirements')
          end
        end
      end
    end

    result
  end

  def self.item_type_title(item             = nil,
                           requirement_type = :high_level,
                           title_type       = :plural)
    result         = ''

    if item.present?
      item   = Item.find(item) if item.kind_of?(Integer)
      result = item.get_item_title(requirement_type, title_type)
    else
      if requirement_type == :low_level
        case title_type
          when :singular
            result = I18n.t('misc.llr')
          when :plural
            result = I18n.t('misc.llrs')
          when :type
            result = I18n.t('misc.llr')
        end
      else
        case title_type
          when :singular
            result = I18n.t('misc.hlr')
          when :plural
            result = I18n.t('misc.hlrs')
          when :type
            result = I18n.t('misc.hlr')
        end
      end
    end

    result
  end
end
