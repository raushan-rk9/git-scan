class RequirementsTracingController < ApplicationController
  include Common

  respond_to    :docx

  before_action :get_item
  before_action :set_session
  before_action { get_project_fromitemid }

  def index
    authorize :requirements_tracing

    sysreq_count    = 0
    hlr_count       = 0
    llr_count       = 0
    sc_count        = 0
    md_count        = 0
    tc_count        = 0
    tp_count        = 0

    if session[:archives_visible]
      sysreq_count  = SystemRequirement.where(project_id:    @project.id,
                                               organization: current_user.organization).length
      hlr_count     = HighLevelRequirement.where(item_id:      params[:item_id],
                                                 organization: current_user.organization).length
      llr_count     = LowLevelRequirement.where(item_id:      params[:item_id],
                                                organization: current_user.organization).length
      md_count      = ModuleDescription.where(item_id:      params[:item_id],
                                              organization: current_user.organization).length
      sc_count      = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization).length
      tc_count      = TestCase.where(item_id:      params[:item_id],
                                     organization: current_user.organization).length
      tp_count      = TestProcedure.where(item_id:      params[:item_id],
                                          organization: current_user.organization).length
    else
      sysreq_count  = SystemRequirement.where(project_id:   @project.id,
                                              organization: current_user.organization,
                                              archive_id:  nil).length
      hlr_count     = HighLevelRequirement.where(item_id:      params[:item_id],
                                                 organization: current_user.organization,
                                                 archive_id:  nil).length
      llr_count     = LowLevelRequirement.where(item_id:      params[:item_id],
                                                organization: current_user.organization,
                                                archive_id:  nil).length
      md_count      = ModuleDescription.where(item_id:      params[:item_id],
                                              organization: current_user.organization,
                                              archive_id:  nil).length
      sc_count      = SourceCode.where(item_id:      params[:item_id],
                                       organization: current_user.organization,
                                       archive_id:  nil).length
      tc_count      = TestCase.where(item_id:      params[:item_id],
                                     organization: current_user.organization,
                                     archive_id:  nil).length
      tp_count      = TestProcedure.where(item_id:      params[:item_id],
                                          organization: current_user.organization,
                                          archive_id:  nil).length
    end

    @sysreq_checked = (sysreq_count > 0)
    @hlr_checked    = (hlr_count > 0)
    @llr_checked    = (llr_count > 0)
    @md_checked     = (md_count > 0)
    @sc_checked     = (sc_count > 0)
    @tc_checked     = (tc_count > 0)
    @tp_checked     = (tp_count > 0)
  end

  def specific
    authorize :requirements_tracing

    @headers     = []
    @reverse     = false
    requirements = if params[:requirements].present?
                     params[:requirements]
                   else
                     "system_requirements,high_level_requirements,low_level_requirements,module_descriptions,source_code,test_cases,test_procedures"
                   end
    requirements = params[:requirements].split(',').delete_if do |requirement|
                     if requirement == 'reversed'
                       @reverse = true
                     else
                       false
                     end
                   end
    project_id   = @project.id if @project.present?
    item_id      = @item.id    if @item.present?

    @matrix      = RequirementsTracing.generate_trace_matrix(requirements,
                                                             @reverse,
                                                             project_id,
                                                             item_id)
    last_row     = []
    @matrix      = @matrix.delete_if do |row|
                     result       = false

                     if row.length == last_row.length
                       result     = true

                       row.each_with_index do |column, index|
                         if column != last_row[index]
                           result = false
                           break
                         end
                       end
                     end

                     last_row     = row

                     result
                   end if @matrix.present?

    requirements.each do |requirement|
      case(requirement)
        when 'system_requirements'
          @headers.push(I18n.t('misc.system_requirements'))
        when /^(.*)high_level_requirements(.*)$/i
          if Regexp.last_match[1].present?
            @headers.push(Regexp.last_match[1] +
                          Item.item_type_title(@item, :high_level, :plural) +
                          Regexp.last_match[2])
          else
            @headers.push(@item.identifier + ' ' +
                          Item.item_type_title(@item, :high_level, :plural) +
                          Regexp.last_match[2])
          end
        when 'low_level_requirements'
          @headers.push(Item.item_type_title(@item, :low_level, :plural))
        when 'module_description', 'module_descriptions'
          @headers.push(I18n.t('module_description.pl_title'))
        when 'source_code', 'source_codes'
          @headers.push(I18n.t('misc.source_code'))
        when 'test_cases'
          @headers.push(I18n.t('misc.test_cases'))
        when 'test_procedures'
          @headers.push(I18n.t('misc.test_procedures'))
      end
    end

    @matrix.each do |row|
      for column in row.length..(@headers.length - 1) do
        row[column] = nil
      end if row.length < @headers.length
    end if @matrix.present?

    respond_to do |format|
      format.html { render 'generic' }
    end
  end

  def unlinked
    authorize :requirements_tracing

    @matrix      = []
    @headers     = []
    requirements = if params[:requirements].present?
                     params[:requirements]
                   else
                     "system_requirements,high_level_requirements,low_level_requirements,module_descriptions,source_code,test_cases,test_procedures"
                   end
    requirements = params[:requirements].split(',').delete_if do |requirement|
      if requirement == 'reversed'
        true
      else
        false
      end
    end if params[:requirements].present?
    project_id   = @project.id if @project.present?
    item_id      = @item.id if @item.present?
    requirements = RequirementsTracing.generate_specialized_hash(params[:requirements],
                                                                 :unlinked,
                                                                 project_id,
                                                                 item_id)

    requirements.each do |requirement_name, items|
      case(requirement_name)
        when 'system_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{I18n.t('misc.system_requirements')}</h5>" ])
        when 'high_level_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{Item.item_type_title(@item, :high_level, :plural)}</h5>" ])
        when 'low_level_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{Item.item_type_title(@item, :low_level, :plural)}</h5>" ])
        when 'module_description', 'module_descriptions'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{I18n.t('module_description.pl_title')}</h5>" ])
        when 'source_code', 'source_codes'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{I18n.t('misc.source_code')}</h5>" ])
        when 'test_cases'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{I18n.t('misc.test_cases')}</h5>" ])
        when 'test_procedures'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unlinked')} #{I18n.t('misc.test_procedures')}</h5>" ])
      end

      items.each { |item| @matrix.push([ item ]) } if items.present?
    end if requirements.present?

    respond_to do |format|
      format.html { render 'generic' }
    end
  end

  def derived
    authorize :requirements_tracing

    @matrix      = []
    @headers     = []
    requirements = if params[:requirements].present?
                     params[:requirements]
                   else
                     "system_requirements,high_level_requirements,low_level_requirements,module_descriptions,source_code,test_cases,test_procedures"
                   end
    requirements = params[:requirements].split(',').delete_if do |requirement|
      if requirement == 'reversed'
        true
      else
        false
      end
    end
    project_id   = @project.id if @project.present?
    item_id      = @item.id if @item.present?
    requirements = RequirementsTracing.generate_specialized_hash(params[:requirements],
                                                                 :derived,
                                                                 project_id,
                                                                 item_id)

    requirements.each do |requirement_name, items|
      case(requirement_name)
        when 'system_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{I18n.t('misc.system_requirements')}</h5>" ])
        when 'high_level_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{Item.item_type_title(@item, :high_level, :plural)}</h5>" ])
        when 'low_level_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{Item.item_type_title(@item, :low_level, :plural)}</h5>" ])
        when 'module_description', 'module_descriptions'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{I18n.t('module_description.pl_title')}</h5>" ])
        when 'source_code', 'source_codes'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{I18n.t('misc.source_code')}</h5>" ])
        when 'test_cases'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{I18n.t('misc.test_cases')}</h5>" ])
        when 'test_procedures'
          @matrix.push([ "<h5>#{I18n.t('hlrs.derived')} #{I18n.t('misc.test_procedures')}</h5>" ])
      end

      items.each { |item| @matrix.push([ item ]) } if items.present?
    end if requirements.present?

    respond_to do |format|
      format.html { render 'generic' }
    end
  end

  def unallocated
    authorize :requirements_tracing

    @matrix      = []
    @headers     = []
    requirements = if params[:requirements].present?
                     params[:requirements]
                   else
                     "system_requirements,high_level_requirements,low_level_requirements,test_cases"
                   end
    requirements = params[:requirements].split(',').delete_if do |requirement|
      if requirement == 'reversed'
        true
      else
        false
      end
    end
    project_id   = @project.id if @project.present?
    item_id      = @item.id if @item.present?
    requirements = RequirementsTracing.generate_specialized_hash(requirements,
                                                                 :unallocated,
                                                                 project_id,
                                                                 item_id)

    requirements.each do |requirement_name, items|
      case(requirement_name)
        when 'system_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unallocated')} #{I18n.t('misc.system_requirements')}</h5>" ])
        when 'high_level_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unallocated')} #{Item.item_type_title(@item, :high_level, :plural)}</h5>" ])
        when 'low_level_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unallocated')} #{Item.item_type_title(@item, :low_level, :plural)}</h5>" ])
        when 'test_cases'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unallocated')} #{I18n.t('misc.test_cases')}</h5>" ])
      end

      items.each { |item| @matrix.push([ item ]) } if items.present?
    end if requirements.present?

    respond_to do |format|
      format.html { render 'generic' }
    end
  end

  def system_allocation
    authorize :requirements_tracing

    last_row     = []
    @headers     = []
    @project     = Project.find(params['project_id']) if @project.nil? &&
                                                         params['project_id'].present?
    requirements = ['system_requirements', 'high_level_requirements']
    @matrix      = RequirementsTracing.generate_trace_matrix(requirements, false,
                                                             @project.id )
    @matrix      = @matrix.delete_if do |row|
                     result       = false

                     if row.length == last_row.length
                       result     = true

                       row.each_with_index do |column, index|
                         if column != last_row[index]
                           result = false
                           break
                         end
                       end
                     end

                     last_row     = row

                     result
                   end if @matrix.present?

    requirements.each_with_index do |requirement, requirement_column|
      case(requirement)
        when 'system_requirements'
          @headers.push(I18n.t('misc.system_requirements'))
        when /^(.*)high_level_requirements(.*)$/i
          if Regexp.last_match[1].present?
            @headers.push(Regexp.last_match[1] + Regexp.last_match[2] + ' ' +
                          Item.item_type_title)
          else
            @matrix.each do |row|
              if row[requirement_column].present? &&
                 row[requirement_column].item_id.present?
                @headers.push(Item.identifier_from_id(row[requirement_column].item_id) + ' ' + Item.item_type_title)

                break
              end
            end if @matrix.present?
          end
        when 'low_level_requirements'
          @headers.push(Item.item_type_title(@item, :low_level, :plural))
        when 'module_description', 'module_descriptions'
          @headers.push(I18n.t('module_description.pl_title'))
        when 'source_code', 'source_codes'
          @headers.push(I18n.t('misc.source_code'))
        when 'test_cases'
          @headers.push(I18n.t('misc.test_cases'))
        when 'test_procedures'
          @headers.push(I18n.t('misc.test_procedures'))
      end
    end

    @matrix.each do |row|
      for column in row.length..(@headers.length - 1) do
        row[column] = nil
      end if row.length < @headers.length
    end if @matrix.present?

    respond_to do |format|
      format.html { render 'generic' }
    end
  end

  def system_unallocated
    authorize :requirements_tracing

    @matrix      = []
    @headers     = []
    @project     = Project.find(params['project_id']) if @project.nil? &&
                                                         params['project_id'].present?
    requirements = if params[:requirements].present?
                     params[:requirements]
                   else
                     "system_requirements"
                   end
    project_id   = @project.id if @project.present?
    item_id      = @item.id if @item.present?
    requirements = RequirementsTracing.generate_specialized_hash(requirements,
                                                                 :unallocated,
                                                                 project_id,
                                                                 item_id)

    requirements.each do |requirement_name, items|
      case(requirement_name)
        when 'system_requirements'
          @matrix.push([ "<h5>#{I18n.t('hlrs.unallocated')} #{I18n.t('misc.system_requirements')}</h5>" ])
      end

      items.each { |item| @matrix.push([ item ]) } if items.present?
    end if requirements.present?

    respond_to do |format|
      format.html { render 'generic' }
    end
  end

  def export
    authorize :requirements_tracing

    if params[:rtm_export].present?
      get_data

      requested_format = params[:rtm_export][:export_type].downcase

      case requested_format
        when 'html'
          render('generic')

        when 'pdf'
          @no_links = true

          render(pdf:         "#{@project.name}-#{@item.name}-Requirements Tracing Matrix",
                 template:    'requirements_tracing/generic.html.erb',
                 title:       'Requirements Tracing: Export Tracing Matrix | PACT',
                 footer:      { right: '[page] of [topage]' },
                 orientation: 'Landscape',)

        when 'csv'
          send_data(RequirementsTracing.save_csv_spreadsheet(@headers,
                                                             @matrix,
                                                             @item),
                    filename: "#{@project.name}-#{@item.name}-Requirements Tracing Matrix.csv")

        when 'xls'
          send_data(RequirementsTracing.save_xls_spreadsheet(@headers,
                                                             @matrix,
                                                             @item),
                    filename: "#{@project.name}-#{@item.name}-Requirements Tracing Matrix.xls")

        when 'docx'
          if convert_data("Requirements Tracing Matrix.docx",
                           'requirements_tracing/generic.html.erb',
                           @item.present? ? @item.id : params[:item_id])

            return_file(@converted_filename)
          end
      end
    else
      respond_to do |format|
        format.html { render(:export, requirements: params[:requirements]) }
        format.json { render(status: :unprocessable_entity) }
      end
    end
  end

private
  def get_data
    @headers     = []
    @reverse     = false
    requirements = if params[:requirements].present?
                     params[:requirements]
                   else
                     "system_requirements,high_level_requirements,low_level_requirements,module_descriptions,source_code,test_cases,test_procedures"
                   end
    requirements = params[:requirements].split(',').delete_if do |requirement|
                     if requirement == 'reversed'
                       @reverse = true
                     else
                       false
                     end
                   end
    project_id   = @project.id if @project.present?
    item_id      = @item.id if @item.present?
    @matrix      = RequirementsTracing.generate_trace_matrix(requirements,
                                                             @reverse,
                                                             project_id,
                                                             item_id)
    last_row     = []
    @matrix      = @matrix.delete_if do |row|
                     result       = false

                     if row.length == last_row.length
                       result     = true

                       row.each_with_index do |column, index|
                         if column != last_row[index]
                           result = false
                           break
                         end
                       end
                     end

                     last_row     = row

                     result
                   end if @matrix.present?

    requirements.each do |requirement|
      case(requirement)
        when 'system_requirements'
          @headers.push(I18n.t('misc.system_requirements'))
        when /^(.*)high_level_requirements(.*)$/i
          @headers.push(Regexp.last_match[1] +
                        Item.item_type_title(@item, :high_level, :plural) +
                        Regexp.last_match[2])
        when 'low_level_requirements'
          @headers.push(Item.item_type_title(@item, :low_level, :plural))
        when 'module_descriptions'
          @headers.push(I18n.t('module_description.pl_title'))
        when 'source_code', 'source_codes'
          @headers.push(I18n.t('misc.source_code'))
        when 'test_cases'
          @headers.push(I18n.t('misc.test_cases'))
        when 'test_procedures'
          @headers.push(I18n.t('misc.test_procedures'))
      end
    end
  end
end
