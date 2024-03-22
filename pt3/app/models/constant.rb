class Constant < ActiveRecord::Base
  def get_label
    self.label
  end

  def get_value
    self.value
  end
end
