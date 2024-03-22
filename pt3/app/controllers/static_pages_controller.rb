class StaticPagesController < ApplicationController

  def home
    authorize :static_page
  end

  def help
    authorize :static_page
  end

  def about
    authorize :static_page
  end

  def contact
    authorize :static_page
  end

end
