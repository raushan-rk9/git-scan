class StaticPagePolicy < ApplicationPolicy
  def home?
    true
  end

  def help?
    true
  end

  def about?
    true
  end

  def contact?
    true
  end
end
