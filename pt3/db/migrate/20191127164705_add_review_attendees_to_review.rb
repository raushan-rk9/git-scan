class AddReviewAttendeesToReview < ActiveRecord::Migration[5.2]
  def up
    add_column    :reviews, :attendees, :text unless Review.column_names.include?('attendees')
  end

  def down
    remove_column :reviews, :attendees        if Review.column_names.include?('attendees')
  end
end
