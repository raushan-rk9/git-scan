byebug
application_controller = ApplicationController.new

application_controller.set_current_database(ARGV[1])

user                   = User.find_by(email: ARGV[0])

if user.present?
  user.id              = nil

  application_controller.set_current_database(ARGV[2])
  user.save!
end
