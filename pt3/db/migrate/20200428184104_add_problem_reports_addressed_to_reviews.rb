class AddProblemReportsAddressedToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :problem_reports_addressed, :string
  end
end
