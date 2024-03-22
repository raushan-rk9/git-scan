class PopupController < ApplicationController
  include ActionView::Helpers::TextHelper
  include Common

  def index
    authorize :popup
    
  end

  def show
    authorize :popup

    @contents = params["contents"]
    @field    = params["field"]

    @field.gsub!("'", '')
    @contents.gsub!(/^'/ , '')
    @contents.gsub!(/'$/ , '')
  end

  def create
    authorize :popup

    @contents = params["contents"]
    @field    = params["field"]

    @field.gsub!("'", '')
    @contents.gsub!(/^'/ , '')
    @contents.gsub!(/'$/ , '')
  end

  def new
    authorize :popup
  end

  def edit
    authorize :popup

    @contents = params["contents"]
    @field    = params["field"]

    @field.gsub!("'", '')
    @contents.gsub!(/^'/ , '')
    @contents.gsub!(/'$/ , '')
  end

  def update
    authorize :popup

    @contents = params["contents"]
    @field    = params["field"]

    @field.gsub!("'", '')
    @contents.gsub!(/^'/ , '')
    @contents.gsub!(/'$/ , '')
  end

  def destroy
    @field    = params["contents"]
    authorize :popup
  
  end
end