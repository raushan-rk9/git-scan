class DataChangesController < ApplicationController
  def undo
    authorize :data_change

    @data_change = DataChange.find(params[:id])

    @return_link = "/" + @data_change.table_name

    if  @data_change.undo
      @undo_path = nil

      format.html { redirect_to @return_link, notice: 'Undo successful.' }
      format.json { render :index, status: :undo, location: @data_change }
    else
      format.html { redirect_to @return_link, error: 'Cannot undo!.' }
      format.json { render json: @data_change.errors, status: :unprocessable_entity }
    end
  end

  def redo
    authorize :data_change

    @data_change = DataChange.find(params[:id])

    @return_link = "/" + @data_change.table_name

    if  @data_change.redo
      @undo_path = nil

      format.html { redirect_to @return_link, notice: 'Undo successful.' }
      format.json { render :index, status: :undo, location: @data_change }
    else
      format.html { redirect_to @return_link, error: 'Cannot undo!.' }
      format.json { render json: @data_change.errors, status: :unprocessable_entity }
    end
  end
end
