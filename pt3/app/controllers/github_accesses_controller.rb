class GithubAccessesController < ApplicationController
  include Common

  before_action :set_github_access_by_id, only:           [
                                                            :show,
                                                            :edit,
                                                            :update,
                                                            :destroy
                                                          ]
  before_action :set_github_access_by_current_user, only: [
                                                            :set_repository,
                                                            :set_branch,
                                                            :set_folder,
                                                            :get_repositories,
                                                            :get_branches,
                                                            :get_folders,
                                                            :get_files
                                                         ]

  # GET /github_access
  # GET /github_access.json
  def index
    @github_accesses = GithubAccess.all
    @undo_path = get_undo_path('github_accesses', github_accesses_path)
    @redo_path = get_redo_path('github_accesses', github_accesses_path)
  end

  # GET /github_access/1
  # GET /github_access/1.json
  def show
    @undo_path = get_undo_path('github_accesses', github_accesses_path)
    @redo_path = get_redo_path('github_accesses', github_accesses_path)
  end

  # GET /github_access/new
  def new
    @github_access         = GithubAccess.new
    @github_access.user_id = current_user.id
    @undo_path = get_undo_path('github_accesses', github_accesses_path)
    @redo_path = get_redo_path('github_accesses', github_accesses_path)
  end

  # GET /github_access/1/edit
  def edit
    @undo_path  = get_undo_path('github_accesses', github_accesses_path)
    @redo_path  = get_redo_path('github_accesses', github_accesses_path)
  end

  # POST /github_access
  # POST /github_access.json
  def create
    @github_access = GithubAccess.new(github_access_params)
    @undo_path     = get_undo_path('github_accesses', github_accesses_path)
    @redo_path     = get_redo_path('github_accesses', github_accesses_path)

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(@github_access,
                                                      'create',
                                                      @github_access.id,
                                                      'github_accesses')
        format.html { redirect_to @github_access, notice: 'Github credential was successfully created.' }
        format.json { render :show, status: :created, location: @github_access }
      else
        format.html { render :new }
        format.json { render json: @github_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /github_access/1
  # PATCH/PUT /github_access/1.json
  def update
    @undo_path = get_undo_path('github_accesses', github_accesses_path)
    @redo_path = get_redo_path('github_accesses', github_accesses_path)
    @item      = Item.find(params[:item_id]) if params[:item_id].present?

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(github_access_params,
                                                      'update',
                                                      params[:id],
                                                      'github_accesses')
        if params[:redirect].present?
          format.html { redirect_to item_source_codes_select_github_files_path(@item) + "?github_access_id=#{params[:id]}" }
          format.json { render :show, status: :ok, location: @github_access }
        else
          format.html { redirect_to @github_access, notice: 'Github credential was successfully updated.' }
          format.json { render :show, status: :ok, location: @github_access }
        end
      else
        format.html { render :edit }
        format.json { render json: @github_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /github_access/1
  # DELETE /github_access/1.json
  def destroy
    @undo_path = get_undo_path('github_accesses', github_accesses_path)
    @redo_path = get_redo_path('github_accesses', github_accesses_path)

    DataChange.save_or_destroy_with_undo_session(@github_access,
                                                 'delete',
                                                 @github_access.id,
                                                 'github_accesses')
    respond_to do |format|
      format.html { redirect_to github_accesses_url, notice: 'Github credential was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def set_repository
    @github_access.last_accessed_repository = params[:id]

    @github_access.save!
    
    @repository = get_current_repository

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => @repository, :status => 200
        end
      }
    end
  end

  def set_branch
    @github_access.last_accessed_branch = params[:id]

    @github_access.save!
    
    @branch = get_current_branch

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => @branch, :status => 200
        end
      }
    end
  end

  def set_folder
    @github_access.last_accessed_folder = params[:id]

    @github_access.save!
    
    @folder = get_current_folder

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => @folder, :status => 200
        end
      }
    end
  end

  def get_repositories
    @github_user    = @github_access.get_github_user if @github_access.present?

    if @github_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error    = "Cannot login to github with your personal token."
        else
          @error    = "Cannot login to github as #{@github_access.username}."
        end
    end

    unless @error.present?
      @repositories = @github_access.get_my_repositories(true);
    end

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => @repositories, :status => 200
        end
      }
    end
  end

  def get_branches
    @github_user    = @github_access.get_github_user if @github_access.present?

    if @github_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error    = "Cannot login to github with your personal token."
        else
          @error    = "Cannot login to github as #{@github_access.username}."
        end
    end

    unless @error.present?
      @branches = @github_access.get_branches(params[:id]);
    end

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => { branches: @branches.map(&:to_h).to_json } , :status => 200
        end
      }
    end
  end

  def get_folders
    @github_user    = @github_access.get_github_user if @github_access.present?

    if @github_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error    = "Cannot login to github with your personal token."
        else
          @error    = "Cannot login to github as #{@github_access.username}."
        end
    end

    unless @error.present?
      @folders = @github_access.get_folders(params[:repository],
                                            params[:id].gsub('|', '/'),
                                             true);
    end

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => { folders: @folders.map(&:to_h).to_json } , :status => 200
        end
      }
    end
  end

  def get_files
    @github_user    = @github_access.get_github_user if @github_access.present?

    if @github_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error    = "Cannot login to github with your personal token."
        else
          @error    = "Cannot login to github as #{@github_access.username}."
        end
    end

    unless @error.present?
      @files = @github_access.get_files_for_folders(params[:id].gsub('|', '/'),
                                                    params[:repository],
                                                    params[:branch].gsub('|', '/'),
                                                    true);
    end

    result = []

    @files.each do |file|
      path = file.path
      url  = file.url
      id   = file.sha

      url.gsub!('//api.', '//')
      url.gsub!('/repos/', '/')
      url.gsub!(/git\/blobs\/.+$/, "blob/#{params[:branch]}/#{path}")

      result.push({ path: path, url: url, id: id })
    end if @files.present?

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => { files: result.to_json }, :status => 200
        end
      }
    end
  end

  def get_file(path)
    @github_user    = @github_access.get_github_user if @github_access.present?

    if @github_access.nil?
      @error        = "Cannot locate your GitHub credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Github Credentials."
    elsif @github_user.nil?
        if @github_access.token.present?
          @error    = "Cannot login to github with your personal token."
        else
          @error    = "Cannot login to github as #{@github_access.username}."
        end
    end

    unless @error.present?
      @files = @github_access.get_files_for_folders(params[:id].gsub('|', '/'),
                                                    params[:repository],
                                                    params[:branch].gsub('|', '/'),
                                                    true);
    end

    result = []

    @files.each do |file|
      path = file.path
      url  = file.url
      id   = file.sha

      url.gsub!('//api.', '//')
      url.gsub!('/repos/', '/')
      url.gsub!(/git\/blobs\/.+$/, "blob/#{params[:branch]}/#{path}")

      result.push({ path: path, url: url, id: id })
    end if @files.present?

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => { files: result.to_json }, :status => 200
        end
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_github_access_by_id
      @github_access = GithubAccess.find_by(id: params[:id])
    end

    def set_github_access_by_current_user
      @github_access  = GithubAccess.find_by(user_id: current_user.id) if current_user.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def github_access_params
      params.require(:github_access).permit(:id, :username, :password, :token, :user_id, :last_accessed_repository, :last_accessed_branch, :last_accessed_folder, :last_accessed_file, :repository_url)
    end
end
