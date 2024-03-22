class ExportPolicy < ApplicationPolicy
  def index?
    !userrole_equal('Demo User')
  end

  def user?
    !userrole_equal('Demo User')
  end

  def review?
    !userrole_equal('Demo User')
  end
end
