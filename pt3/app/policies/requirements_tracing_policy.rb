class RequirementsTracingPolicy < ApplicationPolicy
  def index?
    true
  end

  def specific?
    true
  end

  def unlinked?
    true
  end

  def unallocated?
    true
  end

  def derived?
    true
  end

  def system_allocation?
    true
  end

  def system_unallocated?
    true
  end

  def all?
    true
  end

  def sys_hlr?
    true
  end

  def hlr_llr?
    true
  end

  def hlr_tc?
    true
  end

  def llr_tc?
    true
  end

  def hlr_sc?
    true
  end

  def llr_sc?
    true
  end

  def sys_hlr_llr?
    true
  end

  def sys_hlr_llr_sc?
    true
  end

  def export?
    true
  end
end
