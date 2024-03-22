# app/models/old_password.rb
class OldPassword < ActiveRecord::Base
  validates :encrypted_password,       presence: true
  validates :password_archivable_type, presence: true
  validates :password_archivable_id,   presence: true
end