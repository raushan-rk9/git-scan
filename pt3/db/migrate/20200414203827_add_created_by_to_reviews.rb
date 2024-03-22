class AddCreatedByToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :created_by, :string
  end
end
