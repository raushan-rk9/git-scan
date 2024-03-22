class ProblemReportMailer < ApplicationMailer
  default from: "pact_cm@airworthinesscert.com"
  layout        "mailer"

  def new_email(problem_report_id)
    @problem_report = ProblemReport.find(problem_report_id)
    @project        = Project.find(@problem_report.project_id)
    @item           = Item.find(@problem_report.item_id) if @problem_report.item_id.present?
    @cc_list        = ''

    @project.configuration_managers.each do |email|
      next unless email.present?

      @cc_list      = if @cc_list == ''
                        email
                      else
                        @cc_email + ',' + email
                      end
    end if @project.configuration_managers.present?

    return unless @problem_report.assignedto.present?

    @user           = User.find_by(email: @problem_report.assignedto)

    if @user.present?          &&
       @user.notify_on_changes &&
       (@user.email            != User.current.email)
      message       = mail(template_path: 'problem_report_mailer',
                           template_name: 'new_email',
                           to:            @user.email,
                           cc:            @cc_list,
                           subject:       'A new problem report has been assigned to you.')

      message.deliver!
    end
  end

  def edit_email(problem_report_id)
    @problem_report = ProblemReport.find(problem_report_id)
    @project        = Project.find(@problem_report.project_id)
    @item           = Item.find(@problem_report.item_id) if @problem_report.item_id.present?
    @cc_list        = ''

    @project.configuration_managers.each do |email|
      next unless email.present?

      @cc_list      = if @cc_list == ''
                        email
                      else
                        @cc_email + ',' + email
                      end
    end if @project.configuration_managers.present?

    if @problem_report.assignedto.present?
      @user         = User.find_by(email: @problem_report.assignedto)

      if @user.present?          &&
         @user.notify_on_changes &&
         (@user.email            != User.current.email)
        message     = mail(template_path: 'problem_report_mailer',
                           template_name: 'edit_email',
                           to:            @user.email,
                           cc:            @cc_list,
                           subject:       'A problem report assigned to you has changed.')

        message.deliver!
      end
    end

    if @problem_report.openedby.present?
      @user         = User.find_by(email: @problem_report.openedby)

      if @user.present?          &&
         @user.notify_on_changes &&
         (@user.email            != User.current.email)
        message     = mail(template_path: 'problem_report_mailer',
                           template_name: 'edit_email',
                           to:            @user.email,
                           cc:            @cc_list,
                           subject:       'A problem report opened by you has changed.')

        message.deliver!
      end
    end
  end

  def send_email(problem_report_id, recipients, cc_list = '', comments,
                 attachment_name, attachment_type, attachment_data)
    @problem_report              = ProblemReport.find(problem_report_id)
    @project                     = Project.find(@problem_report.project_id)
    @item                        = Item.find(@problem_report.item_id) if @problem_report.item_id.present?
    @comments                    = comments
    attachments[attachment_name] = {
                                      mime_type: attachment_type,
                                      content:   attachment_data
                                   } if attachment_name.present?
    message                      = mail(template_path: 'problem_report_mailer',
                                        template_name: 'send_email',
                                        to:            recipients,
                                        cc:            cc_list,
                                        subject:       "Problem Report: #{@problem_report.prid}.")

    message.deliver!
  end

  def delete_email(problem_report)
    @problem_report = problem_report
    @project        = Project.find(@problem_report.project_id)
    @item           = Item.find(@problem_report.item_id) if @problem_report.item_id.present?
    @cc_list        = ''

    @project.configuration_managers.each do |email|
      next unless email.present?

      @cc_list      = if @cc_list == ''
                        email
                      else
                        @cc_email + ',' + email
                      end
    end if @project.configuration_managers.present?

    if @problem_report.assignedto.present?
      @user         = User.find_by(email: @problem_report.assignedto)

      if @user.present?          &&
         @user.notify_on_changes &&
         (@user.email            != User.current.email)

        message     = mail(template_path: 'problem_report_mailer',
                           template_name: 'delete_email',
                           to:            @user.email,
                           cc:            @cc_list,
                           subject:       'A problem report assigned to you has been deleted.')

        message.deliver!
      end
    end

    if @problem_report.openedby.present?
      @user         = User.find_by(email: @problem_report.openedby)

      if @user.present?          &&
         @user.notify_on_changes &&
         (@user.email            != User.current.email)
        message     = mail(template_path: 'problem_report_mailer',
                           template_name: 'delete_email',
                           to:            @user.email,
                           cc:            @cc_list,
                           subject:       'A problem opened by you has been deleted.')

        message.deliver!
      end
    end
  end
end
