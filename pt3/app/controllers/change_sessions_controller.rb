class ChangeSessionsController < ApplicationController
  def undo
    authorize :change_session

    unless params['success_path'].present?
      redirect_back(fallback_location: root_path)
    end

    respond_to do |format|
      if ChangeSession.undo(params[:change_session_id])
        @undo_path     = nil
        flash[:notice] = 'Undo successful.'

        if params['success_path'].present?
          format.html { redirect_to params['success_path'] }
          format.json { redirect_to params['success_path'] }
        end
      else
        flash[:alert] = 'Undo failed.'

        format.html { redirect_to :back }
        format.json { render json: @change_session.errors, status: :unprocessable_entity }
      end
    end
  end

  def redo
    authorize :change_session

    unless params['success_path'].present?
      redirect_back(fallback_location: root_path)
    end

    respond_to do |format|
      if ChangeSession.redo(params[:change_session_id])
        @redo_path     = nil
        flash[:notice] = 'Redo successful.'

        if params['success_path'].present?
          format.html { redirect_to params['success_path'] }
          format.json { redirect_to params['success_path'] }
        end
      else
        flash[:alert] = 'Redo failed.'

        format.html { redirect_to :back }
        format.json { render json: @change_session.errors, status: :unprocessable_entity }
      end
    end
  end
end
