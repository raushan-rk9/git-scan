class ImportPolicy < ApplicationPolicy
  def index?
    userrole_match([])
  end
end
