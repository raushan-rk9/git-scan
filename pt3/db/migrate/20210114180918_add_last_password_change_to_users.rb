class AddLastPasswordChangeToUsers < ActiveRecord::Migration[5.2]
  def change
    # other devise fields
    add_column :users, :password_changed_at,      :datetime
    add_column :users, :last_activity_at,         :datetime
    add_column :users, :expired_at,               :datetime
    add_column :users, :unique_session_id,        :string
    add_column :users, :security_question_id,     :integer
    add_column :users, :security_question_answer, :string
  
    create_table :old_passwords do |t|
      t.string   :encrypted_password,       null: false
      t.string   :password_archivable_type, null: false
      t.integer  :password_archivable_id,   null: false
      t.string   :password_salt # Optional. bcrypt stores the salt in the encrypted password field so this column may not be necessary.
      t.datetime :created_at
    end

    add_index  :users, :password_changed_at
    add_index  :users, :last_activity_at
    add_index  :users, :expired_at
    add_index  :old_passwords, [ :password_archivable_type, :password_archivable_id ], name: 'index_password_archivable'

    create_table :security_questions do |t|
      t.string :locale, null: false
      t.string :name,   null: false
    end

    SecurityQuestion.create! locale: :en, name: 'What city did your mother and father get married in?'
    SecurityQuestion.create! locale: :en, name: 'What city were you born in?'
    SecurityQuestion.create! locale: :en, name: 'What is the madenname of your mother?'
    SecurityQuestion.create! locale: :en, name: 'What is the middle name of you father?'
    SecurityQuestion.create! locale: :en, name: 'What was the first name of your best man?'
    SecurityQuestion.create! locale: :en, name: 'What was the first name of you maid of honor?'
    SecurityQuestion.create! locale: :en, name: 'What color was you first car?'
    SecurityQuestion.create! locale: :en, name: 'What is you favrite food?'
    SecurityQuestion.create! locale: :en, name: 'What is you favrite genre of music?'
    SecurityQuestion.create! locale: :en, name: 'What is the city where you got your first job?'
  end
end
  
