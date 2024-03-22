class ChangeSessionPolicy < ApplicationPolicy
  def undo?
    true
  end

  def redo?
    true
  end
end
