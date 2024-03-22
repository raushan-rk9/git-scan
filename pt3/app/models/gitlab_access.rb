class GitlabAccess < OrganizationRecord

  belongs_to           :user

  validate             :either_username_password_or_token_are_populated

  attr_reader          :gitlab_client
  attr_reader          :gitlab_user
  attr_accessor        :current_repository
  attr_accessor        :current_branch
  attr_accessor        :current_file
  attr_accessor        :current_folder
  attr_reader          :current_sha
  attr_reader          :repositories
  attr_reader          :branches
  attr_reader          :files
  attr_reader          :folders

  NETWORK_TIMEOUT      = 600
  API_PATH             = '/api/v4'
  TOKEN_PARAMETER      = '?private_token='
  PROJECTS_PATH        = "#{API_PATH}/projects"
  REPOSITORIES_PATH    = "#{PROJECTS_PATH}#{TOKEN_PARAMETER}"
  BRANCHES_PATH        = '/branches'
  FILES_PATH           = '/repository/files/'
  REF                  = '&ref='
  RAW                  = '/raw'
  TREE_PATH            = '/repository/tree'
  PAGE_PARAMETERS      = "&per_page=10000"
  RECURSIVE_PARAMETERS = "&recursive=true"
  TREE_PARAMETERS      = "#{RECURSIVE_PARAMETERS}#{PAGE_PARAMETERS}"
  PATH_PARAMETERS      = '&path='

  @gitlab_user         = nil
  @current_repository  = nil
  @current_branch      = nil
  @current_file        = nil
  @current_folder      = nil
  @current_sha         = ''
  @repositories        = []
  @branches            = []
  @files               = []
  @folders             = []

  def either_username_password_or_token_are_populated
    result = (username.present? && password.present?) || token.present?

    errors.add(:username,
               "Either Username and Password must be filled in " \
               "or Token must be filled in.") unless result

    result
  end

  def obscure_string(text)
    result = ""

    for i in 1..text.length
      result += '*'
    end
        
    result
  end
  
  def display_password
    obscure_string(password)
  end
  
  def display_token
    obscure_string(token)
  end

  def get_my_repositories(force = false, url = nil)
    unless @repositories.present? && !force
      url               = self.url if url.nil?
      path              = url + REPOSITORIES_PATH + self.token + PAGE_PARAMETERS
      uri               = URI.parse(path)
      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      @repositories     = JSON.parse(response.body) if response.code == "200" &&
                                                       response.body != '{ }'
    end

    result              = @repositories

    return result
  end

  def get_current_repository(repository_name = self.last_accessed_repository,
                             force = false)
    result                        = nil
    @current_repository           = nil

    unless @repositories.present? && !force
      @repositories               = get_my_repositories 
    end

    unless !repository_name.present? || @repositories.nil? || @repositories.empty?
      @repositories.each do |repository|
        if repository['name'] == repository_name
          @current_repository     = repository
          break
        end
      end
    end

    self.last_accessed_repository = @current_repository['name'] if @current_repository.present? &&
                                                                   @current_repository['name']
    result                        = @current_repository

    return result
  end

  def get_branches(repository = @current_repository, force = false, url = nil)
    result         = []

    if repository == nil
      repository   = get_current_repository
    elsif repository.kind_of?(String)
      repository   = get_current_repository(repository)
    end

    return result unless repository.present?

    unless branches.present? && !force
      url               = repository['_links']['repo_branches'] if url.nil?
      path              = url + TOKEN_PARAMETER + self.token
      uri               = URI.parse(path)
      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      @branches         = JSON.parse(response.body) if response.code == "200" &&
                                                       response.body != '{ }'
    end

    result         = @branches

    return result
  end

  def get_current_branch(branch_name = self.last_accessed_branch, force = false)
    result                   = nil
    @branches                = get_branches unless @branches.present? && !force

    unless !branch_name.present? || @branches.empty?
      @branches.each do |branch|
        if branch['name'] == branch_name
          @current_branch     = branch
          break
        end
      end
    end

    result                    = @current_branch
    self.last_accessed_branch = @current_branch['name'] if @current_branch.present? &&
                                                           @current_branch['name']

    return result
  end

  def get_files(repository = @current_repository,
                branch     = @current_branch,
                force      = false,
                url        = nil)
    result          = []

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

    if repository.present? && branch.present?
      url               = repository['_links']['self'] if url.nil?
      path              = url + TREE_PATH + TOKEN_PARAMETER + self.token + TREE_PARAMETERS
      uri               = URI.parse(path)
      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      @files            = JSON.parse(response.body) if response.code == "200" &&
                                                       response.body != '{ }'
    end

    result = @files

    return result
  end

  def get_folders(repository = @current_repository,
                  branch     = @current_branch,
                  force      = false,
                  url        = nil)
    result              = []
    @folders            = []

    if repository == nil
      repository        = get_current_repository
    elsif repository.kind_of?(String)
      repository        = get_current_repository(repository)
    end

    if branch == nil
      branch            = get_current_branch
    elsif branch.kind_of?(String)
      branch            = get_current_branch(branch)
    end

    if repository.present? && branch.present?
      url               = repository['_links']['self'] if url.nil?
      path              = url + TREE_PATH + TOKEN_PARAMETER + self.token + TREE_PARAMETERS
      uri               = URI.parse(path)
      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      @folders          = JSON.parse(response.body) if response.code == "200" &&
                                                       response.body != '{ }'

      @folders.delete_if { |folder| folder['type'] != 'tree' }
    end

    result              = @folders

    return result
  end

  def get_current_folder(folder_name = self.last_accessed_folder,
                         force       = false,
                         url         = nil)
    result               = nil
    @folders             = get_folders unless @folders.present? && !force

    unless !folder_name.present? || folders.empty?
      @folders.each do |folder|
        if folder['name'] == folder_name
          @current_folder = folder
          break
        end
      end
    end

    result                    = @current_folder
    self.last_accessed_folder = @current_folder['name'] if @current_folder.present? &&
                                                           @current_folder['name'].present?

    return result
  end

  def get_files_for_folders(folder,
                            repository = @current_repository,
                            branch     = @current_branch,
                            force      = false,
                            url        = nil)
    result             = []

    if repository == nil
      repository        = get_current_repository
    elsif repository.kind_of?(String)
      repository        = get_current_repository(repository)
    end

    if branch == nil
      branch            = get_current_branch
    elsif branch.kind_of?(String)
      branch            = get_current_branch(branch)
    end

    if repository.present? && branch.present?
      url               = repository['_links']['self'] if url.nil?
      path              = url + TREE_PATH + TOKEN_PARAMETER + self.token +
                          TREE_PARAMETERS + PATH_PARAMETERS + folder
      uri               = URI.parse(path)
      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      @files            = JSON.parse(response.body) if response.code == "200" &&
                                                       response.body != '{ }'

      @files.delete_if { |file| file['type'] != 'blob' }
    end

    @files.each do |file|
      info = get_file_info(file['path'], repository, branch, false, url)

      if info.present? && info['last_commit_id'].present?
        file['external_version'] = info['last_commit_id']
      end
    end if @files.present?

    result              = @files

    return result
  end

  def get_file_contents(path,
                        repository = @current_repository,
                        branch     = @current_branch,
                        force      = false,
                        url        = nil)
    result              = nil

    return result unless path.present?

    file_path           = path.dup

    file_path.gsub!('|', '/')
    file_path.gsub!('^', '.')
    file_path.gsub!('.', '%2e')
    file_path.gsub!('/', '%2f')
    file_path.gsub!(' ', '%20')

    if repository == nil
      repository        = get_current_repository
    elsif repository.kind_of?(String)
      repository        = get_current_repository(repository)
    end

    if branch == nil
      branch            = get_current_branch
    elsif branch.kind_of?(String)
      branch            = get_current_branch(branch)
    end

    if repository.present? && branch.present?
      url               = repository['_links']['self'] if url.nil?
      path              = url + FILES_PATH + file_path + TOKEN_PARAMETER + self.token + REF + branch['name']
      uri               = URI.parse(path)

      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      info              = JSON.parse(response.body)        if response.code == "200" &&
                                                              response.body != '{ }'
      contents          = Base64.decode64(info['content']) if info.present? &&
                                                              info['content'].present?
    end

    result              = contents

    return result
  end
  
  def get_file_info(path,
                    repository = @current_repository,
                    branch     = @current_branch,
                    force      = false,
                    url        = nil)
    result              = nil

    return result unless path.present?

    file_path           = path.dup

    file_path.gsub!('|', '/')
    file_path.gsub!('^', '.')
    file_path.gsub!('.', '%2e')
    file_path.gsub!('/', '%2f')
    file_path.gsub!(' ', '%20')

    if repository == nil
      repository        = get_current_repository
    elsif repository.kind_of?(String)
      repository        = get_current_repository(repository)
    end

    if branch == nil
      branch            = get_current_branch
    elsif branch.kind_of?(String)
      branch            = get_current_branch(branch)
    end

    if repository.present? && branch.present?
      url               = repository['_links']['self'] if url.nil?
      path              = url + FILES_PATH + file_path + TOKEN_PARAMETER + self.token + REF + branch['name']
      uri               = URI.parse(path)

      header            = { }
      http              = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = (uri.scheme == "https")
      http.read_timeout = NETWORK_TIMEOUT
      request           = Net::HTTP::Get.new(uri.request_uri, header)
      response          = http.request(request)
      info              = JSON.parse(response.body)        if response.code == "200" &&
                                                              response.body != '{ }'
    end

    result              = info

    return result
  end
end
