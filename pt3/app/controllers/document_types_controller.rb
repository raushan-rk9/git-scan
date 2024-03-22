class DocumentTypesController < ApplicationController
  include Common

  before_action :set_document_type, only: [:show, :edit, :update, :destroy]

  # GET /document_types
  # GET /document_types.json
  def index
    authorize :document_type

    @document_types = DocumentType.all
    @undo_path      = get_undo_path('document_types', document_types_url)
    @redo_path      = get_redo_path('document_types', document_types_url)
  end

  # GET /document_types/1
  # GET /document_types/1.json
  def show
  end

  # GET /document_types/new
  def new
    authorize :document_type

    @document_type = DocumentType.new
    @undo_path     = get_undo_path('document_types', document_types_url)
    @redo_path     = get_redo_path('document_types', document_types_url)
  end

  # GET /document_types/1/edit
  def edit
    authorize @document_type

    @undo_path     = get_undo_path('document_types', document_types_url)
    @redo_path     = get_redo_path('document_types', document_types_url)
  end

  # POST /document_types
  # POST /document_types.json
  def create
    authorize :document_type

    @document_type = DocumentType.new(document_type_params)

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(@document_type,
                                                                  'create',
                                                                  nil,
                                                                  'document_types')

      if @data_change
        format.html { redirect_to @document_type, notice: 'Document type was successfully created.' }
        format.json { render :show, status: :created, location: @document_type }
      else
        format.html { render :new }
        format.json { render json: @document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /document_types/1
  # PATCH/PUT /document_types/1.json
  def update
    authorize @document_type

    respond_to do |format|
      @data_change = DataChange.save_or_destroy_with_undo_session(document_type_params,
                                                                  'update',
                                                                  params[:id],
                                                                  'document_types')

      if @data_change
        format.html { redirect_to @document_type, notice: 'Document type was successfully updated.' }
        format.json { render :show, status: :ok, location: @document_type }
      else
        format.html { render :edit }
        format.json { render json: @document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document_types/1
  # DELETE /document_types/1.json
  def destroy
    authorize @document_type

    @data_change = DataChange.save_or_destroy_with_undo_session(@document_type,
                                                                'delete')

    if @data_change.present?
      respond_to do |format|
        format.html { redirect_to document_types_url, notice: 'Document type was successfully removed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :index, error: 'Could not delete Document Type.' }
        format.json { render json: @action_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document_type
      @document_type = DocumentType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def document_type_params
      params.require(
                       :document_type
                    )
            .permit(
                       :document_code,
                       :description,
                       :control_category,
                       item_types: [],
                       dal_levels: []
                   )
    end
end
