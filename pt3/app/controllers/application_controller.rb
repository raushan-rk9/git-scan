class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  before_action :set_effective_user
  before_action :set_current_organization
  before_action :set_github_access
  before_action :set_gitlab_access
  after_action :set_latest_pages_visited
  after_action  :restore_database
  before_action :set_current_database

  rescue_from Exception do |exception|
    handle_exception(exception)
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  rescue_from Errno::ENOENT                          do |exception|
    byebug if Rails.env.development?

    Rails.logger.error("Cannt find file: #{exception.message}")
  end

  def handle_exception(exception)
    @@exception_count      = if defined?(@@exception_count)
                               @@exception_count + 1
                             else
                               1
                             end

    unless (defined?(@@handling_exception) && @@handling_exception)   ||
           (defined?(@@exception_count)    && @@exception_count > 10)
      @@handling_exception = true
      message              = "*** - Handling exception. Error: #{exception.message}."

      STDERR.puts(message)
      Rails.logger.error(message)

      if exception.kind_of?(ActiveRecord::ConnectionNotEstablished)
        database = if defined?(@current_database) && @current_database.present?
                     if (@current_database == 'default') ||
                        (@current_database == 'primary')
                       'pact_awc'
                     else
                       @current_database
                     end
                   else
                     nil
                   end
  
        if database.present?
          ActiveRecord::Base.establish_connection(adapter:  'postgresql',
                                                  database: database)
        else
          raise exception
        end
      end

      begin
        email_exception('paul@patmos-eng.com', exception)
      rescue => e
        message          = "*** - Error sending exception email. Error: #{e.message}."

        STDERR.puts(message)
        Rails.logger.error(message)
      end

      @@handling_exception = false
      @@exception_count    = 0

      if !exception.kind_of?(ActiveRecord::ConnectionNotEstablished)
        raise exception
      end
    else
      @@handling_exception = false
      message              = "*** - Exception. Error: #{exception.message}."

      STDERR.puts(message)
      Rails.logger.error(message)
      raise exception
    end
  end

  def email_exception(to, exception)
    message = "Greetings:\n\n"                                                 +
              "An exception has occured in PACT.\n"                            +
              "Detail:\n"                                                      +
              "  Message: " + exception.message + "\n"                         +
              "  Where:   " + exception.backtrace.join("\n                  ") +
              "\n\n"                                                           +
              "PACT Automation\n"                                              +
              "pact_cm@airworthinesscert.com"
    result  = ActionMailer::Base.mail(from:    "paul@airworthinesscert.com",
                                      to:      to,
                                      subject: "PACT Exception",
                                      body:    message).deliver

    return result
  end

  # Set user time zone
  around_action :set_time_zone, if: :current_user

  DEFAULT_DATABASE_CONTROLLER = [
                                   'users',
                                   'users/sessions',
                                   'devise/sessions'
                                ]
  DEFAULT_DATABASE_ACTION     = [
                                   'sign_in',
                                   'save_signin',
                                   'sign_in',
                                   'sign_off',
                                   'switch_organization',
                                   'set_organization'
                                ]
  SKIP_CONTROLLER_ACTIONS      = {
                                    'action_items'               => [ 'new', 'create', 'update', 'destroy' ],
                                    'archives'                   => [ 'new', 'create', 'update', 'destroy' ],
                                    'checklist_items'            => [ 'new', 'create', 'update', 'destroy' ],
                                    'document_attachments'       => [ 'new', 'create', 'update', 'destroy' ],
                                    'document_comments'          => [ 'new', 'create', 'update', 'destroy' ],
                                    'document_types'             => [ 'new', 'create', 'update', 'destroy' ],
                                    'documents'                  => [ 'new', 'create', 'update', 'destroy' ],
                                    'high_level_requirements'    => [ 'new', 'create', 'update', 'destroy' ],
                                    'items'                      => [ 'new', 'create', 'update', 'destroy' ],
                                    'licensees'                  => [ 'new', 'create', 'update', 'destroy' ],
                                    'low_level_requirements'     => [ 'new', 'create', 'update', 'destroy' ],
                                    'model_files'                => [ 'new', 'create', 'update', 'destroy' ],
                                    'module_descriptions'        => [ 'new', 'create', 'update', 'destroy' ],
                                    'problem_report_attachments' => [ 'new', 'create', 'update', 'destroy' ],
                                    'problem_report_histories'   => [ 'new', 'create', 'update', 'destroy' ],
                                    'problem_reports'            => [ 'new', 'create', 'update', 'destroy' ],
                                    'projects'                   => [ 'new', 'create', 'update', 'destroy' ],
                                    'requirements_tracing'       => [ 'new', 'create', 'update', 'destroy' ],
                                    'review_attachments'         => [ 'new', 'create', 'update', 'destroy' ],
                                    'reviews'                    => [ 'new', 'create', 'update', 'destroy' ],
                                    'source_codes'               => [ 'new', 'create', 'update', 'destroy' ],
                                    'system_requirements'        => [ 'new', 'create', 'update', 'destroy' ],
                                    'template_checklist_items'   => [ 'new', 'create', 'update', 'destroy' ],
                                    'template_checklists'        => [ 'new', 'create', 'update', 'destroy' ],
                                    'template_documents'         => [ 'new', 'create', 'update', 'destroy' ],
                                    'templates'                  => [ 'new', 'create', 'update', 'destroy' ],
                                    'test_cases'                 => [ 'new', 'create', 'update', 'destroy' ],
                                    'test_procedures'            => [ 'new', 'create', 'update', 'destroy' ],
                                    'users'                      => [ 'new', 'create', 'update', 'destroy' ]
                                 }.freeze

  def restore_database
    result                                                 = false

    return result if @current_database == 'default'

    @current_database = 'default'

    unless @database_config.present?
      @database_config                                     = YAML.load(File.read(File.join(Rails.root,
                                                                                           'config/database.yml')))

      @database_config.each do |configuration_name, configuration|
        configuration.each do |field_name, value|
          if value =~ /^.*<%=.*$/
            value.gsub!(/<%=\s*/, '')
            value.gsub!(/\s*%>/, '')
            field                                            = eval(value)
            @database_config[configuration_name][field_name] = field
          end
        end
      end if @database_config.present?
    end

    ActiveRecord::Base.establish_connection(@database_config[@current_database]) if @database_config.present?

    result            = true

    return result
  end

  def set_current_database(organization = nil)
    result                = false
    use_default_database  = false
    licensee              = nil
    @current_database     = nil
    use_default_database  = DEFAULT_DATABASE_ACTION.include?(self.action_name)    ||
                            DEFAULT_DATABASE_CONTROLLER.include?(self.controller_path)
    organization          = User.current.try(:organization)            unless organization.present?
    licensee              = Licensee.find_by(identifier: organization) if     !use_default_database &&
                                                                              organization.present?

    if licensee.present?          &&
       licensee.database.present? &&
      if @current_database != licensee.database
        licensee.encrypted_password = ENV.fetch("DBPASSWD") { "railsdb" } unless licensee.encrypted_password.present?

        ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                                host:     ENV.fetch("DBHOST") { "db" },
                                                username: ENV.fetch("DBUSER") { "railsdb" },
                                                password: licensee.encrypted_password,
                                                database: licensee.database)

        @current_database = licensee.database
        result            = licensee.database
      end
    else
      restore_database

      result            = 'default'
    end

    return result
  end

  def authenticate_user!
    super

    if current_user
      if current_user.user_disabled
        redirect_to logout_url, alert: "User disabled." if request.original_url != logout_url
      elsif current_user.password_reset_required 
        if (request.original_url != edit_user_url(current_user)) &&
           (request.original_url != user_url(current_user)) &&
           (request.original_url !=logout_url)
          session[:login_attempts] = if session[:login_attempts].present?
                                       session[:login_attempts] += 1
                                     else
                                        session[:login_attempts] = 1
                                     end

          # This state is checking for a user that has not been logged in
          if current_user.login_state != Constants::LOGGED_IN
            redirect_to edit_user_url(current_user), alert: "Please change your password."
          else
            redirect_to logout_url, alert: "Please try to login again."
          end
        end
      elsif current_user.use_multifactor_authentication.present?
        if current_user.login_state == Constants::LOGGED_OUT
          case(current_user.use_multifactor_authentication)
            when Constants::EMAIL
              current_user.login_state = Constants::EMAIL_CHALLENGE

              current_user.save!
            when Constants::SECURITY_QUESTIONS
              current_user.login_state = Constants::SECURITY_CHALLENGE

              current_user.save!
            when Constants::TEXT_MESSAGE
              current_user.login_state = Constants::TEXT_CHALLENGE

              current_user.save!
          end
        elsif current_user.login_state != Constants::LOGGED_IN
          case(current_user.login_state)
            when Constants::EMAIL_CHALLENGE
              session[:login_attempts] = if session[:login_attempts].present?
                                           session[:login_attempts] += 1
                                         else
                                            session[:login_attempts] = 1
                                         end

              if session[:login_attempts] > 10
                redirect_to user_email_multifactor_challenge_url(current_user)
              else
                redirect_to logout_url, alert: "Please try to login again."
              end
            when Constants::SECURITY_CHALLENGE
              redirect_to user_security_multifactor_challenge_url(current_user)
            when Constants::TEXT_CHALLENGE
              session[:login_attempts] = if session[:login_attempts].present?
                                           session[:login_attempts] += 1
                                         else
                                            session[:login_attempts] = 1
                                         end

              if session[:login_attempts] > 10
                redirect_to user_text_multifactor_challenge_url(current_user)
              else
                redirect_to logout_url, alert: "Please try to login again."
              end
            else
              current_user.login_state = Constants::LOGGED_IN

              current_user.save!
          end
        end
      end
    end
  end

  def skip_controller_actions(session)
    return false unless session.present?

    skip   = SKIP_CONTROLLER_ACTIONS[session[:controller]]

    return false unless skip.present?

    result = skip.include?(session[:action])

    return result
  end

  def get_sessions(for_controller = nil)
    sessions   = nil

    if for_controller.present?
    else
      sessions = session[:latest_pages_visited]

      if !sessions.present?  &&
          cookies.present?   &&
          cookies[:latest_pages_visited].present?
        sessions = JSON.parse(cookies[:latest_pages_visited])
      end
    end

    return sessions
  end

  def save_sessions(current_session)
    return false unless session.present?

    if defined? session
      session[:latest_pages_visited] ||= []
      session[:latest_pages_visited] << current_session
    end

    if (existing_sessions = cookies[:latest_pages_visited]).present?
      existing_sessions              = JSON.parse(existing_sessions)
      existing_sessions.push(current_session)

      cookies[:latest_pages_visited] = existing_sessions.to_json
    else
      cookies[:latest_pages_visited] = [ current_session ].to_json
    end

    return true
  end

  def go_back(marked = nil, for_session = nil)
    sessions = get_sessions(for_session)

    unless sessions.present?
      redirect_to :back
    end

    if marked.present?
      marked_index = nil

      sessions.each_index do |path, index|
        if path[:marked] == marked
          marked_index = index
        end
      end

      if marked_index.present?
        last_page = sessions[marked_index]
        index     = sessions.length

        while index > 0
          sessions.pop

          index -= 1;

          break if index == marked_index;
        end
      end

      if last_page.present?
        session = skip_controller_actions

        redirect_to session
      else
        level     = if params[:level] =~ /^\d+$/
                      sessions.length - (params[:level].to_i + 1)
                    else
                      sessions.length - 2
                    end
        last_page = sessions[level] if level >= 0

        if last_page.present?
          session = skip_controller_actions

          redirect_to session
        else
          redirect_to projects_url
        end
      end
    else
      level     = if params[:level] =~ /^\d+$/
                    sessions.length - (params[:level].to_i + 1)
                  else
                    sessions.length - 2
                  end
      last_page = sessions[level] if level >= 0

      if last_page.present?
        sessions.pop

        redirect_to last_page
      else
        redirect_to projects_url
      end
    end
  end

  def set_latest_pages_visited(marked = nil)
    return unless request.get?
    return if request.xhr?
    return if request.path_parameters[:action] == 'go_back'

    if session[:latest_pages_visited].present?
      session[:latest_pages_visited].shift if session[:latest_pages_visited].length > 20

      history_length = session[:latest_pages_visited].length - 1

      return if (history_length > 0)                                                                                   &&
                (request.path_parameters[:controller] == session[:latest_pages_visited][history_length]["controller"]) &&
                (request.path_parameters[:action]     == session[:latest_pages_visited][history_length]["action"])     &&
                (request.path_parameters[:id]         == session[:latest_pages_visited][history_length]["id"])
    end

    if marked.present?
      request.path_parameters[:marked] = marked
    end

    return if skip_controller_actions(request.path_parameters)

    save_sessions(request.path_parameters)
  end

  def get_session_link(controller, action)
    result             = nil
    index              = session[:latest_pages_visited].length - 1

    session[:latest_pages_visited].reverse_each do |url|
      if (url['controller'] == controller) && (url['action'] == action)
        result         = {}
        result[:link]  = url
        result[:index] = index

        break
      end

      index           -= 1
    end

    return result
  end

  def replace_session_link(controller, action, level = 1)
    link                                  = get_session_link(controller, action)
    index                                 = session[:latest_pages_visited].length - level

    return unless link.present?

    session[:latest_pages_visited][index] = link[:link]

    session[:latest_pages_visited].delete_at(link[:index])
  end

  def set_effective_user
    if current_user.try(:fulladmin) && session[:effective_user].present?
      user                         = User.find_by(id: session[:effective_user],
                                                  organization: User.current.organization)

      if user.present?
        @current_user              = user
        User.current               = user
      end
    end
  end

  def set_pandoc
    unless @pandoc.present?
      @pandoc   = if Rails.env.development?
                    '/usr/local/bin/pandoc'
                  else
                    '/usr/bin/pandoc'
                  end

      @pandoc = ENV['PANDOC'] if ENV['PANDOC'].present?
    end

    return @pandoc
  end

  def pandoc_data_conversion(data,
                             data_type        = "html",
                             document_type    = "docx",
                             destination_file = "converted_document.#{document_type}")
    stdout            = nil
    stderr            = nil
    status            = nil
    @conversion_error = nil
    result            = false

    unless data.present?
      @conversion_error       = logger.error('pandoc_data_conversion: No data to convert.')

      logger.error(@conversion_error)
    end

    unless @conversion_error.present?
      set_pandoc

      begin
        data                  = data.encode("UTF-8", invalid: :replace, undef: :replace)

        Tempfile.create([File.basename(destination_file), 'html'],
                        binmode: true) do |temp_file|
          temp_file.write(data)
          temp_file.rewind

          FileUtils.copy(temp_file.path, "./last_conversion.html")

          command             = "#{@pandoc} -s -f #{data_type} -t #{document_type} --reference-doc=app/templates/custom-reference.dotx \"#{temp_file.path}\" -o \"#{destination_file}\""

          logger.info(command)

          stdout,
          stderr,
          status              = Open3.capture3(command)

          if status.exitstatus == 0
            result            = true
          else
            @conversion_error = "pandoc_data_conversion: Pandoc cannot convert the #{data_type} to #{document_type}."
          end
        end
      rescue IOError          => e
        @conversion_error     = "pandoc_data_conversion: Cannot write data to tempfile. Error #{e.message}."
      rescue  EncodingError   => e
        @conversion_error     = "pandoc_data_conversion: Cannot convert to utf8. Error #{e.message}."
      rescue                  => e
        @conversion_error     = "pandoc_data_conversion: Cannot convert to utf8. Error #{e.message}."
      end
    end

    if @conversion_error.present?
      @conversion_error       += "      \n PanDoc Errors: #{stderr}"                 if stderr.present?
      @conversion_error       += "      \n PanDoc Output: #{stdout}"                 if stdout.present?
      @conversion_error       += "      \n PanDoc Exit Status: #{status.exitstatus}" if status.present?

      logger.error(@conversion_error)
    end

    return result
  end

  def read_file_data(source_file, data_type)
    data   = nil

    if File.readable?(source_file)
      data = File.open(source_file, 'rb') { |file| file.read }
    else
      logger.error("read_file_data: Cannot read data. Error #{e.message}")
    end

    return data
  end

  def pandoc_file_conversion(source_file,
                             data_type        = "html",
                             document_type    = "docx",
                             destination_file = "converted_document.#{document_type}")
    data   = read_file_data(source_file, data_type)
    result = pandoc_data_conversion(data, data_type, document_type, destination_file)
    
    return result
  end

  def convert_data(filename, template_filename, item_id = nil,
                   from_type = 'html', to_type = 'docx')
    result                = nil

    unless item_id.present?
      item_id             = if @item.present?
                              @item.id
                            elsif params[:item_id].present?
                              params[:item_id].to_i
                            else
                              nil
                            end
    end

    if item_id.present?
      @item               = Item.find(item_id)
      @converted_filename = "#{@item.name}-#{filename}"
    else
      @converted_filename = filename
    end

    code                  = render_to_string(template: template_filename,
                                             layout:   false,
                                             formats:  [ from_type.to_sym ])
    result                = pandoc_data_conversion(code,
                                                   from_type,
                                                   to_type,
                                                   @converted_filename)
    result                = result && File.readable?(@converted_filename)

    return result
  end

  def return_file(filename,
                  mime_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    result           = false

    if filename.present? && File.readable?(filename)
      send_file(filename, filename: File.basename(filename), type: mime_type)
  
      flash[:info]   = "Exported: #{File.basename(filename)}."
      result         = true
    else
      flash[:error]  = "Cannot locate file: #{filename}."
      params[:level] = 2
  
      go_back
    end

    return result
  end

private

  def set_github_access
    @github_access = GithubAccess.find_by(user_id: current_user.id) if current_user.present?
  end

  def set_gitlab_access
    @gitlab_access = GitlabAccess.find_by(user_id: current_user.id) if current_user.present?
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

    logger.error "**Access Error** - #{flash[:alert]}, Record: #{exception.policy.record}, Query: #{exception.query}, User: #{exception.policy.user.email}, User Roles: #{exception.policy.user.role}"

    redirect_to request.referrer if request.referrer.present? && (request.referrer != root_path) && !(request.referrer =~ /.*login.*/i)
  end

  def set_current_user
    User.current = current_user
  end

  def set_current_project(project = nil)
    Project.current = project if project.present?
  end

  def set_current_organization(organization = nil)
    unless organization.present?
      organization         = if params['organization'].present?
                               params['organization']
                             elsif session[:organization].present?
                              session[:organization]
                             elsif cookies[:organization].present?
                               cookies[:organization]
                             elsif User.current.present? &&
                                   User.current.organization.present?
                               User.current.organization
                             else
                               nil
                             end
    end

    if organization.present?
      organization.downcase!

      session[:organization]        = organization
      Thread.current[:organization] = organization
      @organization_set             = true
    end

    return organization
  end

  def get_current_organization
    session[:organization]
  end

  # Set user time zone
  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def set_organization_cookie
    organization                       = get_current_organization

    if organization.present?
      domain                           = if (Rails.env == 'development') ||
                                            (Rails.env == 'test')
                                           'localhost'
                                         else
                                           'faaconsultants.com'
                                         end
      cookies.permanent[:organization] = {
                                            value:    organization,
                                            expires:  1.year,
                                            domain:   domain,
                                            path:     '/',
                                            secure:   false,
                                            httponly: false,
                                         }
    end
  end

  def get_cookies
    organization = cookies[:organization]

    set_current_organization(organization)
  end

  def delete_cookies
    cookies.delete :organization
  end

end
