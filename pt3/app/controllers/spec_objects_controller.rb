class SpecObjectsController < ApplicationController
  before_action :set_spec_object, only: [:show, :edit, :update, :destroy]

  # GET /spec_objects
  # GET /spec_objects.json
  def index
    @spec_objects = SpecObject.all
  end

  # GET /spec_objects/1
  # GET /spec_objects/1.json
  def show
  end

  # GET /spec_objects/new
  def new
    @spec_object = SpecObject.new
  end

  # GET /spec_objects/1/edit
  def edit
  end

  # POST /spec_objects
  # POST /spec_objects.json
  def create
    @spec_object = SpecObject.new(spec_object_params)

    respond_to do |format|
      if @spec_object.save
        format.html { redirect_to @spec_object, notice: 'Spec object was successfully created.' }
        format.json { render :show, status: :created, location: @spec_object }
      else
        format.html { render :new }
        format.json { render json: @spec_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /spec_objects/1
  # PATCH/PUT /spec_objects/1.json
  def update
    respond_to do |format|
      if @spec_object.update(spec_object_params)
        format.html { redirect_to @spec_object, notice: 'Spec object was successfully updated.' }
        format.json { render :show, status: :ok, location: @spec_object }
      else
        format.html { render :edit }
        format.json { render json: @spec_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spec_objects/1
  # DELETE /spec_objects/1.json
  def destroy
    @spec_object.destroy
    respond_to do |format|
      format.html { redirect_to spec_objects_url, notice: 'Spec object was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_spec_object
      @spec_object = SpecObject.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def spec_object_params
      params.require(:spec_object).permit(:type, :data, :value)
    end
end
