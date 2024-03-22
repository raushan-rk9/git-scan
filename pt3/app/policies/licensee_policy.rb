class LicenseePolicy < ApplicationPolicy
  def index?
    userrole_match(['AirWorthinessCert Member'])
  end

  def show?
    userrole_match(['AirWorthinessCert Member'])
  end

  def create?
    userrole_match(['AirWorthinessCert Member'])
  end

  def update?
    userrole_match(['AirWorthinessCert Member'])
  end

  def destroy?
    userrole_match(['AirWorthinessCert Member'])
  end
end
