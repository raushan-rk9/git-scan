class AddReviewSignOffsToReviews < ActiveRecord::Migration[5.2]
  def up
    add_column    :reviews, :sign_offs, :text unless Review.column_names.include?('sign_offs')
  end

  def down
    remove_column :reviews, :sign_offs        if Review.column_names.include?('sign_offs')
  end
end
