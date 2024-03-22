class CreateProblemReports < ActiveRecord::Migration[5.1]
  def change
    create_table :problem_reports do |t|
      t.references :project, foreign_key: true
      t.references :item,    foreign_key: true
      t.integer    :prid
      t.datetime   :dateopened
      t.string     :status
      t.string     :openedby
      t.string     :title
      t.string     :product
      t.string     :criticality
      t.string     :source
      t.string     :discipline_assigned
      t.string     :assignedto
      t.datetime   :target_date
      t.datetime   :close_date
      t.text       :description
      t.string     :problemfoundin
      t.text       :correctiveaction
      t.string     :fixed_in
      t.string     :verification
      t.text       :feedback
      t.text       :notes
      t.string     :meeting_id
      t.boolean    :safetyrelated
      t.datetime   :datemodified

      t.timestamps
    end
  end
end
