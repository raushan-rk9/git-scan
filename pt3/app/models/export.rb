# http://railscasts.com/episodes/219-active-model
class Export
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :export_type
  attr_accessor :project_select
  attr_accessor :item_select

  validates_presence_of :export_type

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
