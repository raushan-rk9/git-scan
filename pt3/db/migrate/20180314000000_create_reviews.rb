class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    unless ActiveRecord::Base.connection.table_exists? 'reviews'
      create_table :reviews do |t|
        t.integer :reviewid
        t.string :reviewtype
        t.string :title
        t.string :evaluators
        t.date :evaldate
        t.string :description
        t.integer :version
        t.references :item, foreign_key: true
        t.references :project, foreign_key: true

        # Use to keep counters for ID based models.
        t.integer :clitem_count, default: 0
        t.integer :ai_count, default: 0
        t.text    :attendees
  
        t.timestamps
      end
    end
  end
end
