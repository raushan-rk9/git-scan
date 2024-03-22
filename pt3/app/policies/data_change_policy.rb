class DataChangePolicy < ApplicationPolicy
  def undo?
    true
  end

  def redo?
    true
  end
end
