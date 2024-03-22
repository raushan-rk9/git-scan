# app/models/security_question.rb
class SecurityQuestion < ActiveRecord::Base
  validates :locale, presence: true
  validates :name,   presence: true, uniqueness: true
end