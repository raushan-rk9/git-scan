class ErrorsController < ApplicationController
  include Common

  def not_found
    redirect_to root_path

    render status: 404
  end

  def unacceptable
    redirect_to root_path

    render status: 422
  end

  def internal_error
    redirect_to root_path

    render status: 500
  end
end
