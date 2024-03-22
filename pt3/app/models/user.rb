class User <  ApplicationRecord
  has_one    :github_access,    dependent: :destroy, required: false
  has_one    :gitlab_access,    dependent: :destroy, required: false
  has_many   :project_accesses, dependent: :destroy
  belongs_to :checklist_item,   required: false

  has_one_attached :signature_file,  dependent: false
  has_one_attached :profile_picture, dependent: false

  has_one_time_password

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :lockable, :recoverable, :rememberable,
         :trackable, :validatable, :timeoutable, :omniauthable,
         omniauth_providers: %i[github]
         #, :registerable

  # Define role and organizations as an array type.
  serialize :role,          Array
  serialize :organizations, Array

  # Accessors
  attr_accessor :selected
  attr_accessor :challenge_code

  # Define roles
  User_Roles = [
    'AirWorthinessCert Member',
    'Project Manager',
    'Configuration Management',
    'Quality Assurance',
    'Team Member',
    'View Only',
    'Restricted View',
    'Certification Representative',
    'Demo User'
  ]

  # Define roles
  Organization_Roles = [
    'Project Manager',
    'Configuration Management',
    'Quality Assurance',
    'Team Member',
    'View Only',
    'Restricted View',
    'Certification Representative'
  ]

  # Generate first and last name.
  def fullname
    "#{firstname} #{lastname}"
  end

  # Simple Form default label.
  def to_label
    fullname
  end

  def self.fullname_from_email(email)
    result = ''
    user   = User.find_by(email: email, organization: User.current.organization)
    result = user.fullname if user.present?

    return result
  end

  def self.organization_or_role(organization, roles)
    result = []
    users  = User.all

    users.each do |user|
      if user.organization == organization
        result.push(user)
      else
        user.role.each do |role|
          next unless role.present?

          if roles.include?(role)
            result.push(user)

            break
          end
        end
      end
    end

    result.sort! { |x, y| x.fullname <=> y.fullname}

    return result
  end

  def remember_me
    false
  end

  def remember_for
    30.seconds
  end

# *************************
# *** DATABASE ROUTINES ***
# *************************

  # ***********
  # * Setters *
  # ***********

  def self.set_database(database = 'pact_awc',
                        host     = nil,
                        username = nil,
                        password = nil,
                        adapter  = nil)
    return nil unless database.present?

    begin
      current_database   = nil

      begin
        current_database = ActiveRecord::Base.connection.current_database
      rescue => e
        current_database = nil
      end

      return current_database if current_database == database

      host               = ENV.fetch("DBHOST") { "db" }        unless host.present?
      username           = ENV.fetch("DBUSER") { "railsdb" }   unless username.present?
      password           = ENV.fetch("DBPASSWD") { "railsdb" } unless password.present?
      adapter            = 'postgresql'                        unless adapter.present?
      result             = ActiveRecord::Base.establish_connection(adapter: adapter,
                                                                   host:     host,
                                                                   username: username,
                                                                   password: password,
                                                                   database: database)
    rescue => e
      Rails.logger.error("Can't switch to #{database}. Error: #{e.message}.")
    end

    return result
  end

  def self.copy_users(source_database, destination_database)
    result                    = false
    old_database              = ActiveRecord::Base.connection.current_database

    User.set_database(source_database) if old_database != source_database

    users                     = User.all

    unless users.present?
      User.set_database(old_database)

      return result
    end

    User.set_database(destination_database)

    users.each do |user|
      existing_user           = User.find_by(email: user.email)

      if existing_user.present?
        user.id = existing_user.id if existing_user.id != user.id

        existing_user.update!(user.as_json)
      else
        user.id               = nil

        user.save!
      end
    end

    User.set_database(old_database)

    result                    = true

    return result
  end

  # Create csv
  def self.to_csv
    attributes = %w{id email encrypted_password}

    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.current_organization
    Thread.current[:organization]
  end

  def self.current_organization=(organization)
    Thread.current[:organization] = organization
  end

  def self.set_user(user)
    User.current            = user
    user.login_state        = Constants::LOGGED_IN
    user.current_sign_in_at = DateTime.now
    user.last_sign_in_at    = DateTime.now

    user.save!
  end

  # Method:      parse_name
  # Parameters:  name a string, the name to parse;
  #              wanted an optional sym (default: original), the name wanted:
  #                  :original
  #                  :full_name
  #                  :last_name
  #                  :first_name
  #                  :middle_name
  #                  :first_and_last_name
  #                  :nickname
  #                  :second_full_name
  #                  :second_last_name
  #                  :second_first_name
  #                  :second_middle_name
  #                  :second_first_and_last_name
  #                  :second_nickname
  # Return:      An string the name or nil if there is none.
  # Description: Parses a name and returns it.
  # Calls:       None
  # Notes:       Formats Handled: Last, First [Middle] or First [Middle] Last
  # History:     04-15-2015 - First Written

  def self.parse_name(parse_name, wanted = :original, reversed = false)
    result              = nil

    unless name.nil?
      name              = parse_name.clone
      original_name     = name.clone
      first_name        = nil
      middle_name       = nil
      last_name         = nil
      nickname          = nil

      if name.index(/\s+(&|and)\s+/i)
        names = name.split(/\s+(&|and)\s+/i)

        case wanted
          when :second_full_name
            wanted = :full_name
            name   = names[1]

          when :second_last_name
            wanted = :last_name
            name   = names[1]

          when :second_first_name
            wanted = :first_name
            name   = names[1]

          when :second_middle_name
            wanted = :middle_name
            name   = names[1]

          when :second_first_and_last_name
            wanted = :first_and_last_name
            name   = names[1]

          when :second_nickname
            wanted = :nickname
            name   = names[1]

          else
            name = names[0]
        end
      else
        case wanted
          when :second_full_name,
               :second_full_name,
               :second_last_name,
               :second_first_name,
               :second_middle_name,
               :second_first_and_last_name,
               :second_nickname
            return result
        end
      end

      if name =~ /^.*(\s*".+"\s*).*$/
        nickname = $1.strip

        name.gsub!(nickname, ' ')
      elsif name =~ /^.*(\s*'.+'\s*).*$/
        nickname = $1.strip

        name.gsub!(nickname, ' ')
      end

      name.squeeze!(' ')

      if name.index(',').nil? && !reversed
        if name =~/^(['a-zA-Z.]+)\s+([-'a-zA-Z.]+)\s+([-'a-zA-Z.]+)$/
          first_name    = $1.strip
          middle_name   = $2.strip
          last_name     = $3.strip
        elsif name =~/^([-'a-zA-Z.]+)\s+([-'a-zA-Z.]+)$/
          first_name    = $1.strip
          last_name     = $2.strip
        else
          fields        = name.split(/\s+/)

          if fields.length > 3
            first_name  = fields[0]
            middle_name = fields[1]
            last_name   = ''

            for i in 2..(fields.length - 1)
              last_name     += ' ' if last_name != ''
              last_name     += fields[i]
            end
          else
            last_name   = name
          end
        end
      else
        names           = []
        names[0]        = ''
        names[1]        = nil

        if reversed
          space         = name.index(' ')

          unless space.nil?
            names[0]    = name[0..(space - 1)]
            names[1]    = name[(space + 1)..-1]
          else
            names[0]    = name
          end
        else
          names         = name.split(',')
        end

        last_name       = names[0].strip

        unless names[1].nil?
          names[1].strip!

          if names[1]   =~/^([-'a-zA-Z.]+)\s+([-'a-zA-Z.]+)$/
            first_name  = $1.strip
            middle_name = $2.strip
          else
            first_name  = names[1].strip
          end
        end
      end

      case wanted
        when :original
          result        = original_name
        when :nickname
          result        = nickname
        when :first_and_last_name
          if !middle_name.nil? && (first_name =~ /^[A-Za-z]\.$/) # Handle names like C. Thomas Howell
            first_name  = middle_name
            middle_name = nil
          end

          if !first_name.nil? && !last_name.nil?
            result      = "#{first_name} #{last_name}"
          elsif !last_name.nil?
            result      = last_name
          elsif !first_name.nil?
            result      = first_name
          end
        when :first_name
          if !middle_name.nil? && (first_name =~ /^[A-Za-z]\.$/) # Handle names like C. Thomas Howell
            first_name  = middle_name
            middle_name = nil
          end

          result        = first_name
        when :middle_name
          if !middle_name.nil? && (first_name =~ /^[A-Za-z]\.$/) # Handle names like C. Thomas Howell
            first_name  = middle_name
            middle_name = nil
          end

          result        = middle_name
        when :last_name
          result        = last_name
        else
          if !first_name.nil? && !middle_name.nil? && !last_name.nil?
            result      = "#{first_name} #{middle_name} #{last_name}"
          elsif !first_name.nil? && !last_name.nil?
            result      = "#{first_name} #{last_name}"
          elsif !last_name.nil?
            result      = last_name
          elsif !first_name.nil?
            result      = first_name
          end
      end
    end

    return result
  end

  # Method:      is_name?
  # Parameters:  line a string, the line to check.
  # Return:      A Boolean, true if we think this is a name.
  # Description: Checks to see if a line contains a name.
  # Calls:       None
  # Notes:       
  # History:     03-31-2016 - First Written

  def self.is_name?(line)
    name_line                  = line.strip
    result                     = 0
    ideal_count                = 2

    return false              if name_line =~ /^\d.*/

    if name_line.index(/\s+/)
      reversed                 = false
      index                    = 0
      fields                   = name_line.split(/\s+/)

      fields.each do |field|
        return false          if field =~ /^\d+S/
        
        if index == 0
          if field =~ /^["']?[A-Z](\.|\.[A-Z]\.|[A-Aa-z]*'[A-Za-z]+|[-A-Za-z]+)["']?,?$/
            result            += 1
            reversed           = (field =~ /^.+,$/)
          elsif (field =~ /(mr|ms|mrs|miss|madam|dame|lord|sir|dr|rev)\.?/i)
            result            += 1
            ideal_count       += 1
          elsif (field =~ /\d(st|nd|rd|th)/)
            result            += 1
            ideal_count       += 1
          else
            return false
          end
        elsif index > 0 && (index < (fields.length - 1))
          if reversed
            if field =~ /^["']?[A-Z](\.|[A-Aa-z]*'[A-Za-z]+|[-A-Za-z]+)?["']?$/
              result          += 1
            else
              if reversed
                if (field.gsub('.', '') =~ /(mr|ms|mrs|miss|madam|dame|lord|sir|dr|rev)\.?/i)
                  result      += 1
                  ideal_count += 1
                else
                  return false
                end
              else
                if (field.gsub('.', '') =~ /(&|and|md|phd|dds|jr|esq),?/i)
                  result      += 1
                  ideal_count += 1
                  reversed     = (field =~ /^.+,$/)
                elsif (field =~ /\d(st|nd|rd|th)/)
                  result      += 1
                  ideal_count += 1
                  reversed     = (field =~ /^.+,$/)
                else
                  return false
                end
              end
            end
          else
            if field =~ /^["']?[A-Z](\.|[A-Aa-z]*'[A-Za-z]+|[-A-Za-z]+)?["']?,?$/
              result          += 1
            elsif (field =~ /(rn|dds|md|phd)\.?/i)
              result          += 1
              ideal_count     += 1
            elsif (field =~ /(&|and)\.?/i)
              result          -= 4
              ideal_count     += 3
            else
              return false
            end
          end
        elsif index == (fields.length - 1)
          if reversed
            if field =~ /^["']?[A-Z](\.|\.[A-Z]\.|[A-Aa-z]*'[A-Za-z]+|[-A-Za-z]+)?["']?$/
              result          += 1
            elsif (field =~ /(mr|ms|mrs|miss|madam|lord|sir|dr)\.?/i)
              result          += 1
              ideal_count     += 1
            else
              return false
            end
          else
            if field =~ /^[A-Z](\.|\.[A-Z]\.|[A-Aa-z]*'[A-Za-z]+|[-A-Za-z]+)$/
              result          += 1
            elsif (field =~ /\d(st|nd|rd|th)/)
              result          += 1
              ideal_count     += 1
            else
              return false
            end
          end
        end

        index                 += 1
      end
    else
      if line =~ /^[A-Z](\.|\.[A-Z]\.|[A-Aa-z]*'[A-Za-z]+|[-A-Za-z]+)$/
        result                 = 1
      else
        result                 = false
      end
    end

    result                    += 10 if (index == ideal_count)
    result                    +=  9 if (index == (ideal_count + 1))

    return result
  end

  def self.from_omniauth(auth)
    user                        = self.current

    if user.nil?
      user                      = User.find_by(email: auth.info.email,
                                               organization: User.current.organization)

      if user.nil?
        parameters              = {
                                    email:     auth.info.email,
                                    password:  Devise.friendly_token[0, 20],
                                    firstname: self.parse_name(auth.info.name,
                                                                 :first_name),
                                    lastname:  self.parse_name(auth.info.name,
                                                                 :last_name),
                                    role:      [ 'Restricted View' ]
                                  }

        user                    = User.new(parameters)
        user.email              = auth.info.email
        user.encrypted_password = Devise.friendly_token[0, 20]
        user.firstname          = self.parse_name(auth.info.name, :first_name)
        user.lastname           = self.parse_name(auth.info.name, :last_name)
        user.role               = [ 'Restricted View' ]
      end
    end

    user.provider               = auth.provider
    user.uid                    = auth.uid

    # ToDo Add this. Add image and parse name into first and last name
    # user.image = auth.info.image # assuming the user model has an image

    user.save!

    user
  end

  def forget_me!
    current_user = User.current

    if current_user.present?
      current_user.login_state = Constants::LOGGED_OUT

      current_user.save!
    end

    super
  end
end
