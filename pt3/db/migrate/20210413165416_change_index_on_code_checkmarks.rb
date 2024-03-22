class ChangeIndexOnCodeCheckmarks < ActiveRecord::Migration[5.2]
  def change
    add_index :code_checkmarks, [ :filename, :checkmark_id ], unique: true unless index_name_exists?(:code_checkmarks,
                                                                                                     [ :filename, :checkmark_id ])
  end
end
