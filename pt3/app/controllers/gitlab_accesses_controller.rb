class GitlabAccessesController < ApplicationController
  include Common

  before_action :set_gitlab_access_by_id, only:           [
                                                            :show,
                                                            :edit,
                                                            :update,
                                                            :destroy
                                                          ]
  before_action :set_gitlab_access_by_current_user, only: [
                                                            :set_repository,
                                                            :set_branch,
                                                            :set_folder,
                                                            :get_repositories,
                                                            :get_branches,
                                                            :get_folders,
                                                            :get_files
                                                         ]

  # GET /gitlab_access
  # GET /gitlab_access.json
  def index
    @gitlab_accesses = GitlabAccess.all
    @undo_path = get_undo_path('gitlab_accesses', gitlab_accesses_path)
    @redo_path = get_redo_path('gitlab_accesses', gitlab_accesses_path)
  end

  # GET /gitlab_access/1
  # GET /gitlab_access/1.json
  def show
    @undo_path = get_undo_path('gitlab_accesses', gitlab_accesses_path)
    @redo_path = get_redo_path('gitlab_accesses', gitlab_accesses_path)
  end

  # GET /gitlab_access/new
  def new
    @gitlab_access         = GitlabAccess.new
    @gitlab_access.user_id = current_user.id
    @undo_path = get_undo_path('gitlab_accesses', gitlab_accesses_path)
    @redo_path = get_redo_path('gitlab_accesses', gitlab_accesses_path)
  end

  # GET /gitlab_access/1/edit
  def edit
    @undo_path = get_undo_path('gitlab_accesses', gitlab_accesses_path)
    @redo_path = get_redo_path('gitlab_accesses', gitlab_accesses_path)
  end

  # POST /gitlab_access
  # POST /gitlab_access.json
  def create
    @gitlab_access = GitlabAccess.new(gitlab_access_params)
    @gitlab_access = GitlabAccess.new(gitlab_access_params)
    @undo_path     = get_undo_path('gitlab_accesses', gitlab_accesses_path)

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(@gitlab_access,
                                                      'create',
                                                      @gitlab_access.id,
                                                      'gitlab_accesses')
        format.html { redirect_to @gitlab_access, notice: 'Gitlab credential was successfully created.' }
        format.json { render :show, status: :created, location: @gitlab_access }
      else
        format.html { render :new }
        format.json { render json: @gitlab_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gitlab_access/1
  # PATCH/PUT /gitlab_access/1.json
  def update
    @undo_path = get_undo_path('gitlab_accesses', gitlab_accesses_path)
    @redo_path = get_redo_path('gitlab_accesses', gitlab_accesses_path)
    @item      = Item.find(params[:item_id]) if params[:item_id].present?

    respond_to do |format|
      if DataChange.save_or_destroy_with_undo_session(gitlab_access_params,
                                                      'update',
                                                      params[:id],
                                                      'gitlab_accesses')
        if params[:redirect].present?
          format.html { redirect_to item_source_codes_select_gitlab_files_path(@item) + "?gitlab_access_id=#{params[:id]}" }
          format.json { render :show, status: :ok, location: @gitlab_access }
        else
          format.html { redirect_to @gitlab_access, notice: 'Gitlab credential was successfully updated.' }
          format.json { render :show, status: :ok, location: @gitlab_access }
        end
      else
        format.html { render :edit }
        format.json { render json: @gitlab_access.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gitlab_access/1
  # DELETE /gitlab_access/1.json
  def destroy
    @undo_path = get_undo_path('gitlab_accesses', gitlab_accesses_path)
    @redo_path = get_redo_path('gitlab_accesses', gitlab_accesses_path)

    DataChange.save_or_destroy_with_undo_session(@gitlab_access,
                                                 'delete',
                                                 @gitlab_access.id,
                                                 'gitlab_accesses')
    respond_to do |format|
      format.html { redirect_to gitlab_accesses_url, notice: 'Gitlab credential was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def set_repository
    @gitlab_access.last_accessed_repository = params[:id]

    @gitlab_access.save!

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
    @gitlab_access.last_accessed_branch = params[:id]

    @gitlab_access.save!
    
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
    @gitlab_access.last_accessed_folder = params[:id]

    @gitlab_access.save!
    
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
    if @gitlab_access.nil?
      @error        = "Cannot locate your Gitlab credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Gitlab Credentials."
    end

    unless @error.present?
      @repositories = @gitlab_access.get_my_repositories(true)
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
    if @gitlab_access.nil?
      @error        = "Cannot locate your Gitlab credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Gitlab Credentials."
    end

    unless @error.present?
      @branches = @gitlab_access.get_branches(params[:id])
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
    if @gitlab_access.nil?
      @error        = "Cannot locate your Gitlab credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Gitlab Credentials."
    end

    unless @error.present?
      @folders = @gitlab_access.get_folders(params[:repository],
                                            params[:id].gsub('|', '/'),
                                             true)
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
    if @gitlab_access.nil?
      @error        = "Cannot locate your Gitlab credentials "              \
                      "Have you entered them?\nIf not you can do so under " \
                      "Info > Setup Gitlab Credentials."
    end

    unless @error.present?
      @files = @gitlab_access.get_files_for_folders(params[:id].gsub('|', '/'),
                                                    params[:repository],
                                                    params[:branch].gsub('|', '/'),
                                                    true)
    end

    result     = []
    repository =  @gitlab_access.current_repository['path_with_namespace']
    branch     = params[:branch].gsub('|', '/')

    @files.each do |file|
      path = file['path']
      url  = @gitlab_access.url + '/' + repository + '/blob/' + branch + '/' + path
      id   = file['external_id']

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

  def get_file_contents
    if @gitlab_access.nil?
      @error    = "Cannot locate your Gitlab credentials "              \
                  "Have you entered them?\nIf not you can do so under " \
                  "Info > Setup Gitlab Credentials."
    end

    unless @error.present?
      @filename = params[:id].gsub('|', '/').gsub('^', '.')
      @contents = @gitlab_access.get_file_contents(params[:id].gsub('|', '/'),
                                                   params[:repository],
                                                   params[:branch].gsub('|', '/'),
                                                   true)
    end

    respond_to do |format|
      format.html {
        if @error.present?
          render :nothing => true, :status => 500, :content_type => 'text/html'
        else
          send_data @contents, filename: File.basename(@filename)
        end
      }

      format.json {
        if @error.present?
          render :json => { error: @error }, :status => 500
        else
          render :json => { contents: @contents }, :status => 200
        end
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gitlab_access_by_id
      @gitlab_access = GitlabAccess.find_by(id: params[:id])
    end

    def set_gitlab_access_by_current_user
      @gitlab_access  = GitlabAccess.find_by(user_id: current_user.id) if current_user.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gitlab_access_params
      params.require(:gitlab_access).permit(:id, :username, :password, :token, :url, :user_id, :last_accessed_repository, :last_accessed_branch, :last_accessed_folder, :last_accessed_file)
    end
end
