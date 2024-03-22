class CodeCheckmarkHitsController < ApplicationController
  before_action :set_code_checkmark_hit, only: [:show, :edit, :update, :destroy]
  before_action :set_code_checkmark,     only: [:show, :edit, :update, :destroy, :index]
  before_action :set_source_code,        only: [:show, :edit, :update, :destroy, :index]
  before_action :set_item,               only: [:show, :edit, :update, :destroy, :index]

  # GET /code_checkmark_hits
  # GET /code_checkmark_hits.json
  def index
    if @code_checkmark.present?
      @code_checkmark_hits     = CodeCheckmarkHit.where(code_checkmark_id: @code_checkmark.id,
                                                        organization: current_user.organization)
    elsif @source_code.present?
      @code_checkmark_hits     = []
      @code_checkmarks         = CodeCheckmark.where(source_code_id: @source_code.id,
                                                     organization: current_user.organization)

      @code_checkmarks.each do |code_checkmark|
        code_checkmark_hits    = CodeCheckmarkHit.where(code_checkmark_id: code_checkmark.id,
                                                        organization: current_user.organization)

        code_checkmark_hits.each do |code_checkmark_hit|
          @code_checkmark_hits.push(code_checkmark_hit)
        end unless code_checkmark_hits.empty?
      end unless @code_checkmarks.empty?
    else
      @code_checkmark_hits     = CodeCheckmarkHit.where(organization: current_user.organization)
    end
    
    if @code_checkmarks.present?
      @code_conditional_blocks = []

      @code_checkmarks.each do |code_checkmark|
        code_conditional_blocks = CodeConditionalBlock.where(source_code_id: code_checkmark.source_code_id)

        code_conditional_blocks.each do |code_conditional_block|
          next if @code_conditional_blocks.find do |block|
            block.id == code_conditional_block.id
          end

          @code_conditional_blocks.push(code_conditional_block)
        end if code_conditional_blocks.present?
      end
    end
  end

  # GET /code_checkmark_hits/1
  # GET /code_checkmark_hits/1.json
  def show
  end

  # GET /code_checkmark_hits/new
  def new
    @code_checkmark_hit = CodeCheckmarkHit.new
  end

  # GET /code_checkmark_hits/1/edit
  def edit
  end

  # POST /code_checkmark_hits
  # POST /code_checkmark_hits.json
  def create
    @code_checkmark_hit = CodeCheckmarkHit.new(code_checkmark_hit_params)

    respond_to do |format|
      if @code_checkmark_hit.save
        format.html { redirect_to @code_checkmark_hit, notice: 'Code checkmark hit was successfully created.' }
        format.json { render :show, status: :created, location: @code_checkmark_hit }
      else
        format.html { render :new }
        format.json { render json: @code_checkmark_hit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /code_checkmark_hits/1
  # PATCH/PUT /code_checkmark_hits/1.json
  def update
    respond_to do |format|
      if @code_checkmark_hit.update(code_checkmark_hit_params)
        format.html { redirect_to @code_checkmark_hit, notice: 'Code checkmark hit was successfully updated.' }
        format.json { render :show, status: :ok, location: @code_checkmark_hit }
      else
        format.html { render :edit }
        format.json { render json: @code_checkmark_hit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_checkmark_hits/1
  # DELETE /code_checkmark_hits/1.json
  def destroy
    @code_checkmark_hit.destroy
    respond_to do |format|
      format.html { redirect_to code_checkmark_hits_url, notice: 'Code checkmark hit was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code_checkmark_hit
      @code_checkmark_hit = CodeCheckmarkHit.find(params[:id]) if params[:id].present?
    end

    def set_code_checkmark
      if params[:code_checkmark_id].present?
        @code_checkmark = CodeCheckmark.find(params[:code_checkmark_id])
      elsif @code_checkmark_hit.present?
        @code_checkmark = CodeCheckmark.find(@code_checkmark_hit.code_checkmark_id)
      end
    end

    def set_source_code
      if params[:source_code_id].present?
        @source_code = SourceCode.find(params[:source_code_id])
      elsif @code_checkmark.present?
        @source_code = SourceCode.find(@code_checkmark.source_code_id)
      end
    end

    def set_item
      if params[:item_id].present?
        @item = Item.find(params[:item_id])
      elsif @source_code.present?
        @item = Item.find(@source_code.item_id)
      end

      unless @project.present?
        @project = Project.find(@item.project_id) if @item.present?
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_checkmark_hit_params
      params.require(:code_checkmark_hit).permit(:code_checkmark_id, :hit_at)
    end
end
