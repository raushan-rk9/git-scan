class ImportController < ApplicationController
  def index
    authorize :import
  end
end
