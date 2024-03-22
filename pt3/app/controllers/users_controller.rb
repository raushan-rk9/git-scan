class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_password, :switch_user]
  skip_before_action :authenticate_user!, only: [
                                                   :email_multifactor_challenge,
                                                   :text_multifactor_challenge,
                                                   :security_multifactor_challenge
                                                ]
  def index
    authorize :user
    @users = if current_user.fulladmin && (current_user.organization == 'global')
               User.all.order(:email)
             else
               User.where(organization: current_user.organization).order(:email)
             end
  end

  def show
    authorize :user
  end

  def new
    authorize :user

    @user              = User.new
    @user.organization = current_user.organization if current_user.organization != 'global'
    @organizations     = current_user.organizations

    if current_user.fulladmin
      @organizations      = Licensee.all.to_a
      licensee            = Licensee.new
      licensee.identifier = 'global'
      licensee.name       = 'Global'

      @organizations.push(licensee)
    end
  end

  def edit
    authorize @user

    @organizations = current_user.organizations

    if current_user.fulladmin
      @organizations      = Licensee.all.to_a
      licensee            = Licensee.new
      licensee.identifier = 'global'
      licensee.name       = 'Global'

      @organizations.push(licensee)
    end

  end

  def create
    authorize :user

    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        begin
          attachment_data                          = File.read(File.join(Rails.root,
                                                                         'public',
                                                                         'PACT-Users-Guide.pdf')).force_encoding('UTF-8')
          mailer                                   = UserMailer.new

          mailer.new_email(@user.id, 'application/pdf', 'PACT-Users-Guide.pdf', attachment_data)
        rescue => e
          flash[:error]                            = "Could not send email. Error: #{e.message}."

          format.html { redirect_to user_path(@user), error: "Could not send email. Error: #{e.message}." }
          format.json { render :show, status: :created, location: @user }

          return
        end

        format.html { redirect_to user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if  current_user.email != @user.email
      authorize @user
    end

    respond_to do |format|
      params[:user][:password_reset_required] = false if @user.password_reset_required

      params[:user].delete(:password) unless params[:user][:password].present?

      if @user.update(user_params)
        if user_params['signature_file'].present?
          file                                = user_params['signature_file']

          file.tempfile.rewind

          begin
            @user.signature_file.attach(io:           file.tempfile,
                                        filename:     file.original_filename,
                                        content_type: file.content_type)
          rescue Errno::EACCES
            @user.signature_file.attach(io:           file.tempfile,
                                        filename:     file.original_filename,
                                        content_type: file.content_type)
          end
        end

        if user_params['profile_picture'].present?
          file                                = user_params['profile_picture']

          file.tempfile.rewind

          begin
            @user.profile_picture.attach(io:           file.tempfile,
                                         filename:     file.original_filename,
                                         content_type: file.content_type)
          rescue Errno::EACCES
            @user.profile_picture.attach(io:           file.tempfile,
                                         filename:     file.original_filename,
                                         content_type: file.content_type)
          end
        end

        if current_user.email != @user.email
          begin
            mailer                                   = UserMailer.new

            mailer.edit_email(@user.id)
          rescue => e
            flash[:error]                            = "Could not send email. Error: #{e.message}."

            format.html { redirect_to user_path(@user), error: "Could not send email. Error: #{e.message}." }
            format.json { render :show, status: :created, location: @user }
  
            return
          end
        end

        format.html { redirect_to user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @user

    if current_user.email != @user.email
      begin
        mailer                                   = UserMailer.new

        mailer.delete_email(@user.id)
      rescue => e
        flash[:error]                            = "Could not send email. Error: #{e.message}."

        format.html { redirect_to users_path, error: "Could not send email. Error: #{e.message}." }
        format.json { render :show, status: :created, location: @user }

        return
      end
    end

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def switch_organization
    authorize :user

    @user          = current_user

    if current_user.fulladmin
      @organizations      = Licensee.all.to_a
      licensee            = Licensee.new
      licensee.identifier = 'global'
      licensee.name       = 'Global'

      @organizations.push(licensee)
    else
      @organizations = []

      current_user.organizations.each do |organization|
        next unless organization.present?

        licensee = Licensee.find_by(identifier: organization)

        @organizations.push(licensee) if licensee.present?
      end if current_user.organizations.present?
    end

    flash[:error]  = 'Please remember to close previous tabs as the organization has changed.'

    respond_to do |format|
      format.html { render :switch_organization, error: 'Please remember to close previous tabs as the organization has changed.' }
    end
  end

  def set_organization
    authorize :user

    new_organization            = user_params['organization'].downcase if user_params['organization'].present?

    if new_organization.present?
      current_user.organization = user_params['organization'].downcase

      set_current_organization(user_params['organization'].downcase)

      Thread.current[:user]     = current_user

      current_user.save!
    end

    respond_to do |format|
      format.html { redirect_to :root }
    end
  end

  def change_password
  end

  def email_multifactor_challenge
    @user = current_user

    if request.post?
      if user_params[:use_multifactor_authentication] != @user.use_multifactor_authentication
        case(user_params[:use_multifactor_authentication])
          when Constants::EMAIL
            @user.use_multifactor_authentication = Constants::EMAIL

            @user.save!
            redirect_to user_email_multifactor_challenge_url(current_user)
          when Constants::TEXT_MESSAGE
            @user.use_multifactor_authentication = Constants::TEXT_MESSAGE

            @user.save!
            redirect_to user_text_multifactor_challenge_path(current_user)
          when Constants::SECURITY_QUESTIONS
            @user.use_multifactor_authentication = Constants::SECURITY_QUESTIONS

            @user.save!

            redirect_to user_security_multifactor_challenge_url(current_user)
        end

        return
      else
        if user_params[:challenge_code] == @user.otp_secret_key
          current_user.login_state = Constants::LOGGED_IN
  
          current_user.save!
  
          redirect_to projects_url

          return
        end
      end
    end

    if @user.present?
      begin
        mailer         = EmailChallengeMailer.new

        mailer.send_code(@user.id)
      rescue => e
        flash[:error]  = "Could not send email : #{@user.email}. Error: #{e.message}."
      end
    end
  end
  
  def text_multifactor_challenge
    @user = current_user

    if request.post?
      if user_params[:use_multifactor_authentication] != @user.use_multifactor_authentication
        case(user_params[:use_multifactor_authentication])
          when Constants::EMAIL
            @user.use_multifactor_authentication = Constants::EMAIL

            @user.save!
            redirect_to user_email_multifactor_challenge_url(current_user)
          when Constants::TEXT_MESSAGE
            @user.use_multifactor_authentication = Constants::TEXT_MESSAGE

            @user.save!
            redirect_to user_text_multifactor_challenge_path(current_user)
          when Constants::SECURITY_QUESTIONS
            @user.use_multifactor_authentication = Constants::SECURITY_QUESTIONS

            @user.save!

            redirect_to user_security_multifactor_challenge_url(current_user)
        end

        return
      else
        if user_params[:challenge_code] == @user.otp_secret_key
          current_user.login_state = Constants::LOGGED_IN
  
          current_user.save!
  
          redirect_to projects_url
        end
      end
    end
  end
  
  def security_multifactor_challenge
    @user = current_user

    if request.post?
      if user_params[:use_multifactor_authentication] != @user.use_multifactor_authentication
        case(user_params[:use_multifactor_authentication])
          when Constants::EMAIL
            @user.use_multifactor_authentication = Constants::EMAIL

            @user.save!
            redirect_to user_email_multifactor_challenge_url(current_user)
          when Constants::TEXT_MESSAGE
            @user.use_multifactor_authentication = Constants::TEXT_MESSAGE

            @user.save!
            redirect_to user_text_multifactor_challenge_path(current_user)
          when Constants::SECURITY_QUESTIONS
            @user.use_multifactor_authentication = Constants::SECURITY_QUESTIONS

            @user.save!

            redirect_to user_security_multifactor_challenge_url(current_user)
        end

        return
      else
        answer = SecurityQuestion.find(@user.security_question_answer) if @user.security_question_answer

        if answer.present? && user_params[:challenge_code] == answer.name
          current_user.login_state = Constants::LOGGED_IN
  
          current_user.save!
  
          redirect_to projects_url
        end
      end
    else
      @challenge_question = SecurityQuestion.find(@user.security_question_id) if @user.security_question_id
    end
  end

  def switch_user
    authorize :user

    @user                          = current_user

    if request.post?
      if user_params[:email].present?
        user                       = User.find_by(email: user_params[:email],
                                                  organization: User.current.organization)

        begin
          User.set_user(user)

          session[:effective_user] = user.id

          redirect_to login_url
        rescue => e
          flash[:error] = "Could not change user. Error: #{e.message}."

          respond_to do |format|
            format.html { redirect_to user_path(@user), error: "Could not change user. Error: #{e.message}." }
            format.json { render :show, status: :created, location: @user }
          end

          return
        end

      end
    end
  end

  def copy_user
    authorize @user

    @organizations = get_organizations

    if request.post?                                  &&
      user_params[:email].present?                    &&
      user_params[:source_organization].present?      &&
      user_params[:destination_organization].present?
      source_database      = OrganizationRecord.get_database_for_organization(user_params[:source_organization])
      destination_database = OrganizationRecord.get_database_for_organization(user_params[:destination_organization])

      if source_database.present?      &&
         destination_database.present? &&
         User.copy_user(user_params[:email], source_database, destination_database)
        respond_to do |format|
          format.html { redirect_to users_path, notice: "Copied #{user_params[:email]} from #{source_database} to #{destination_database}." }
          format.json { redirect_to users_path  }
        end
      else
        flash[:error]      = "Could not copy user. Error: #{e.message}."

        respond_to do |format|
          format.html { redirect_to users_path, error: "Could not copy user. Error: #{e.message}." }
          format.json { redirect_to users_path  }
        end
      end

      return
    end
  end

  def copy_users
    authorize :user

    @organizations = get_organizations

    if request.post?                                  &&
      user_params[:source_organization].present?      &&
      user_params[:destination_organization].present?
      source_database      = OrganizationRecord.get_database_for_organization(user_params[:source_organization])
      destination_database = OrganizationRecord.get_database_for_organization(user_params[:destination_organization])

      if source_database.present?      &&
         destination_database.present? &&
         User.copy_users(source_database, destination_database)
        respond_to do |format|
          format.html { redirect_to users_path, notice: "Copied users from #{source_database} to #{destination_database}." }
          format.json { redirect_to users_path  }
        end
      else
        flash[:error]      = "Could not copy users. Error: #{e.message}."

        respond_to do |format|
          format.html { redirect_to users_path, error: "Could not copy users. Error: #{e.message}." }
          format.json { redirect_to users_path  }
        end
      end

      return
    end
  end

  def get_organizations
    organizations         = Licensee.all.to_a

    if User.current.fulladmin
      licensee            = Licensee.new
      licensee.identifier = 'global'
      licensee.name       = 'Global'

      organizations.push(licensee)
    end

    return organizations
  end

  private
    def set_user
      if params[:id].present?
        @user = User.find(params[:id])
      elsif params[:user_id].present?
        @user = User.find(params[:user_id])
      end
    end

    def user_params
      # If the password field is blank, do not permit the password to be set. This will prevent a blank password from being interpreted and changed.
      if params[:user][:password].blank?
        params.require(
                        :user
                      ).
                      permit(
                               :email,
                               :firstname,
                               :lastname,
                               :time_zone,
                               :fulladmin,
                               :organization,
                               :notify_on_changes,
                               :user_disabled,
                               :password_reset_required,
                               :title,
                               :phone,
                               :signature_file,
                               :profile_picture,
                               :password_reset_required,
                               :use_multifactor_authentication,
                               :challenge_code,
                               role: []
                            )
      else
        params.require(
                         :user
                      ).
                      permit(
                               :email,
                               :password,
                               :encrypted_password,
                               :firstname,
                               :lastname,
                               :time_zone,
                               :fulladmin,
                               :organization,
                               :notify_on_changes,
                               :user_disabled,
                               :password_reset_required,
                               :use_multifactor_authentication,
                               :challenge_code,
                               :title,
                               :phone,
                               :signature_file,
                               :profile_picture,
                               organizations: [],
                               role: []
                            )
      end
    end
end
