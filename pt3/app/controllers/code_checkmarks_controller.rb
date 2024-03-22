class CodeCheckmarksController < ApplicationController
  before_action :set_code_checkmark,     only: [:show, :edit, :update, :destroy]
  before_action :set_item,               only: [:show, :edit, :update, :destroy, :index]
  before_action :set_source_code,        only: [:show, :edit, :update, :destroy, :index]

  # GET /code_checkmarks
  # GET /code_checkmarks.json
  def index
    if @source_code.present?
      @code_checkmarks = CodeCheckmark.where(source_code_id: @source_code.id,
                                             organization: current_user.organization)
    else
      @code_checkmarks = CodeCheckmark.where(organization: current_user.organization)
    end

    if request.url.index('code_checkmark_misses').present?
      @code_checkmarks = @code_checkmarks.to_a.delete_if { |checkmark| checkmark.code_checkmark_hit_ids.present? }
    end
  end

  # GET /code_checkmarks/1
  # GET /code_checkmarks/1.json
  def show
  end

  # GET /code_checkmarks/new
  def new
    @code_checkmark = CodeCheckmark.new
  end

  # GET /code_checkmarks/1/edit
  def edit
  end

  # POST /code_checkmarks
  # POST /code_checkmarks.json
  def create
    @code_checkmark = CodeCheckmark.new(code_checkmark_params)

    respond_to do |format|
      if @code_checkmark.save
        format.html { redirect_to @code_checkmark, notice: 'Code checkmark was successfully created.' }
        format.json { render :show, status: :created, location: @code_checkmark }
      else
        format.html { render :new }
        format.json { render json: @code_checkmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_checkmarks/1
  # PATCH/PUT /code_checkmarks/1.json
  def update
    respond_to do |format|
      if @code_checkmark.update(code_checkmark_params)
        format.html { redirect_to @code_checkmark, notice: 'Code checkmark was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_checkmark }
      else
        format.html { render :edit }
        format.json { render json: @code_checkmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_checkmarks/1
  # DELETE /code_checkmarks/1.json
  def destroy
    @code_checkmark.destroy
    respond_to do |format|
      format.html { redirect_to code_checkmarks_url, notice: 'Code checkmark was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_checkmark
      if request.url.index('by_source_code').nil?
        @code_checkmark = CodeCheckmark.find(params[:id])
      end
    end

    def set_item
      @item = Item.find(params[:item_id]) if params[:item_id].present?

      unless @project.present?
        @project = Project.find(@item.project_id) if @item.present?
      end
    end

    def set_source_code
      @source_code = SourceCode.find(params[:source_code_id]) if params[:source_code_id].present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_checkmark_params
      params.require(:code_checkmark).permit(:checkmark_id, :source_code_id, :filename, :line_number)
    end
end
