class RenameEvaluatorToEvaluators < ActiveRecord::Migration[5.1]
  def up
    rename_column :reviews, :evaluator, :evaluators if Review.column_names.include?('evaluator')  && !Review.column_names.include?('evaluators')
  end

  def down
    rename_column :reviews, :evaluators, :evaluator if Review.column_names.include?('evaluators') && !Review.column_names.include?('evaluator')
  end
end
