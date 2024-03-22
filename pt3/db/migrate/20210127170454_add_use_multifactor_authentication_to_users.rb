class AddUseMultifactorAuthenticationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :use_multifactor_authentication, :string
    add_column :users, :login_state,                    :string
  end
end
