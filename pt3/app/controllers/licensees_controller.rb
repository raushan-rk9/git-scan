class LicenseesController < ApplicationController
  include Common

  before_action :set_licensee, only: [:show, :edit, :update, :destroy]

  # GET /licensees
  # GET /licensees.json
  def index
    authorize :licensee

    @licensees = Licensee.all
    @undo_path = get_undo_path('licensees', licensees_path)
    @redo_path = get_redo_path('licensees', licensees_path)
  end

  # GET /licensees/1
  # GET /licensees/1.json
  def show
    authorize @licensee

    @undo_path = get_undo_path('licensees', licensees_path)
    @redo_path = get_redo_path('licensees', licensees_path)
  end

  # GET /licensees/new
  def new
    authorize :licensee

    @licensee = Licensee.new
  end

  # GET /licensees/1/edit
  def edit
    authorize @licensee
  end

  # POST /licensees
  # POST /licensees.json
  def create
    authorize :licensee

    params[:licensee][:contact_emails] = params[:licensee][:contact_emails].split(/[ ,]\s*/) if params[:licensee][:contact_emails].present?
    @licensee                          = Licensee.new(licensee_params)

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(@licensee,
                                                      'create',
                                                      @licensee.id,
                                                      'licensees')
        format.html { redirect_to @licensee, notice: 'Licensee was successfully created.' }
        format.json { render :show, status: :created, location: @licensee }
      else
        format.html { render :new }
        format.json { render json: @licensee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /licensees/1
  # PATCH/PUT /licensees/1.json
  def update
    authorize @licensee

    params[:licensee][:contact_emails] = params[:licensee][:contact_emails].split(/[ ,]\s*/) if params[:licensee][:contact_emails].present?

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(licensee_params,
                                                      'update',
                                                      params[:id],
                                                      'licensees')
        format.html { redirect_to @licensee, notice: 'Licensee was successfully updated.' }
        format.json { render :show, status: :ok, location: @licensee }
      else
        format.html { render :edit }
        format.json { render json: @licensee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /licensees/1
  # DELETE /licensees/1.json
  def destroy
    authorize @licensee

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(@licensee,
                                                      'delete',
                                                      @licensee.id,
                                                      'licensees')
        format.html { redirect_to licensees_url, notice: 'Licensee was successfully removed.' }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @licensee.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_licensee
      @licensee = Licensee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def licensee_params
      params.require(
                       :licensee
                    )
            .permit(
                       :identifier,
                       :name,
                       :description,
                       :setup_date,
                       :license_date,
                       :license_type,
                       :renewal_date,
                       :administrator,
                       :database,
                       :password,
                       :encrypted_password,
                       :contact_information,
                       contact_emails: [])
    end
end
