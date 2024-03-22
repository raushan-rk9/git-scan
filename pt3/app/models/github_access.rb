class GithubAccess < OrganizationRecord

  belongs_to          :user

  validate            :either_username_password_or_token_are_populated

  attr_reader         :github_client
  attr_reader         :github_user
  attr_accessor       :current_repository
  attr_accessor       :current_branch
  attr_accessor       :current_file
  attr_accessor       :current_folder
  attr_reader         :current_sha
  attr_reader         :repositories
  attr_reader         :branches
  attr_reader         :files
  attr_reader         :folders

  NETWORK_TIMEOUT     = 600
  @github_client      = nil
  @github_user        = nil
  @current_repository = nil
  @current_branch     = nil
  @current_file       = nil
  @current_folder     = nil
  @current_sha        = ''
  @repositories       = []
  @branches           = []
  @files              = []
  @folders            = []

  def either_username_password_or_token_are_populated
    result = (username.present? && password.present?) || token.present?

    errors.add(:username,
               "Either Username and Password must be filled in " \
               "or Token must be filled in.") unless result

    result
  end

  def self.get_github_access()
    GithubAccess.find_by(user_id: User.current.id)
  end

  def obscure_string(text)
    result = ""

    for i in 1..text.length
      result += '*'
    end if text.present?
        
    result
  end
  
  def display_password
    obscure_string(password)
  end
  
  def display_token
    obscure_string(token)
  end

  def get_github_client(force = false)
    result = nil

    unless @github_client.present? && !force
      if token.present?
        @github_client = Octokit::Client.new(access_token: token)
      else
        @github_client = Octokit::Client.new(login:    username,
                                             password: password)
      end
    end

    result = @github_client
    
    return result
  end
  
  def get_github_user(force = false)
    result = nil

    unless @github_user.present? && !force
      @github_client = get_github_client   unless @github_client.present?
      @github_user   = @github_client.user if     @github_client.present?
    end

    result = @github_user
    
    return result
  end

  def get_my_repositories(force = false)
    result          = []
    @github_client  = get_github_client unless @github_client.present? &&
                                              !force

    unless @github_client.nil? || (@repositories.present? && !force)
      @repositories = @github_client.repos({},
                                           query:
                                                  {
                                                    sort: 'asc'
                                                  }
                                          )
    end

    result          = @repositories

    return result
  end

  def get_current_repository(repository_name = self.last_accessed_repository,
                             force = false)
    result                    = nil
    @current_repository       = nil

    unless @repositories.present? && !force
      @repositories           = get_my_repositories 
    end

    unless !repository_name.present? || @repositories.empty?
      @repositories.each do |repository|
        if repository.name == repository_name
          @current_repository = repository
          break
        end
      end
    end

    result                    = @current_repository
    return result
  end

  def get_branches(repository = @current_repository, force = false)
    result         = []

    if repository == nil
      repository   = get_current_repository
    elsif repository.kind_of?(String)
      repository   = get_current_repository(repository)
    end

    return result unless repository.present?

    @github_client  = get_github_client unless @github_client.present? && !force

    unless @github_client.nil? || (branches.present? && !force)
      @branches      = @github_client.branches(repository.id)
    end

    result         = @branches

    return result
  end

  def get_current_branch(branch_name = self.last_accessed_branch, force = false)
    result                = nil
    @branches             = get_branches unless @branches.present? && !force

    unless !branch_name.present? || @branches.empty?
      @branches.each do |branch|
        if branch.name == branch_name
          @current_branch = branch
          break
        end
      end
    end

    result                = @current_branch
    return result
  end

  def get_files(repository = @current_repository,
                branch     = @current_branch,
                force      = false)
    result          = []
    @github_client  = get_github_client unless @github_client.present? && !force

    if repository == nil
      repository   = get_current_repository
    elsif repository.kind_of?(String)
      repository   = get_current_repository(repository)
    end

    if branch == nil
      branch   = get_current_branch
    elsif branch.kind_of?(String)
      branch   = get_current_branch(branch)
    end

    if branch.present?                   &&
       branch.kind_of?(Sawyer::Resource) &&
       (!@files.present? || force)
      @current_sha  = branch[:commit][:sha] 
      files         = @github_client.tree(repository.id,
                                          @current_sha,
                                          :recursive => true)
      @files        = files[:tree] if files.present?
    end

    result = @files

    return result
  end

  def get_file(folder, file_name)
    result = nil
    files  = get_files_for_folders(folder)
    path   = folder + '/' + file_name

    files.each do |file|
      if path == file.path
        result = file

        return result
      end
    end

    return result
  end

  def get_file_contents(path,
                        repository = @current_repository,
                        branch     = @current_branch,
                        force      = false,
                        url        = nil)
    result                    = nil

    return result unless path.present?

    file = get_file(path.split(/\//)[0], path.split(/\//)[1])

    if repository == nil
      repository              = get_current_repository
    elsif repository.kind_of?(String)
      repository              = get_current_repository(repository)
    end

    if branch == nil
      branch                  = get_current_branch
    elsif branch.kind_of?(String)
      branch                  = get_current_branch(branch)
    end

    if repository.present? && branch.present? && file.present? && file.url.present?
      url                     = file.url
      uri                     = URI.parse(url)
      header                  = {}
      header['Authorization'] = "token #{self.token}"
      header['Content-Type']  = 'Content-Type'
      http                    = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl            = (uri.scheme == "https")
      http.read_timeout       = NETWORK_TIMEOUT
      request                 = Net::HTTP::Get.new(uri.request_uri, header)
      response                = http.request(request)
      info                    = JSON.parse(response.body)        if response.code == "200" &&
                                                                    response.body != '{ }'
      contents                = Base64.decode64(info['content']) if info.present? &&
                                                                    info['content'].present?
    end

    result                    = contents

    return result
  end

  def get_folders(repository = @current_repository,
                  branch     = @current_branch,
                  force      = false)
    result                   = []
    @folders                 = []

    unless   @folders.present? && !force
      unless @files.present?   && !force
        @files               = get_files(repository, branch, force)

        if @files.present?
          @files.each do |entry|
            if entry.type == 'tree'
              @folders.push(entry)
            end
          end
        end
      end
    end

    result                   = @folders

    return result
  end

  def get_current_folder(folder_name = self.last_accessed_folder, force = false)
    result                = nil
    @folders             = get_folders unless @folders.present? && !force

    unless !folder_name.present? || folders.empty?
      @folders.each do |folder|
        if folder.path == folder_name
          @current_folder = folder
          break
        end
      end
    end

    result                = @current_folder
    return result
  end

  def get_files_for_folders(folder,
                            repository = @current_repository,
                            branch     = @current_branch,
                            force      = false)
    result             = []

    return result unless folder.present?

    folder_name_length = folder.length

    unless @files.present? && !force
      @files           = get_files(repository, branch, force)
    end

    @files.each do |file|
      if (file.path.index(folder) == 0)          &&
         (file.path.length > folder_name_length) &&
         (file.type != 'tree')
        result.push(file)
      end
    end if  @files.present?

    return result
  end
end
