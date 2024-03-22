Rails.application.routes.draw do
  resources :logs
  resources :spec_objects
  resources :licensees
  resources :document_types
  resources :project_accesses
  devise_for :users, :skip => [:registrations], :path_prefix => 'd', controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # Admin pages for Users
  resources :users do
    match '/switch_user',                            to: 'users#switch_user',                    via: [:get, :put, :patch, :post]
    match '/switch_organization',                    to: 'users#switch_organization',            via: [:get, :put, :patch, :post]
    match '/set_organization',                       to: 'users#set_organization',               via: [:get, :put, :patch, :post]
    match '/copy_user',                              to: 'users#copy_user',                      via: [:get, :put, :patch, :post]
    match '/copy_users',                             to: 'users#copy_users',                     via: [:get, :put, :patch, :post]
    match '/edit/:id',                               to: 'users#edit',                           via: [:get, :put, :patch, :post]
    match '/change_password',                        to: 'users#change_password',                via: [:get, :put, :patch, :post]
    match '/email_multifactor_challenge',            to: 'users#email_multifactor_challenge',    via: [:put, :patch, :post]
    match '/email_multifactor_challenge',            to: 'users#email_multifactor_challenge',    via: [:get]
    match '/text_multifactor_challenge',             to: 'users#text_multifactor_challenge',     via: [:put, :patch, :post]
    match '/text_multifactor_challenge',             to: 'users#text_multifactor_challenge',     via: [:get]
    match '/security_multifactor_challenge',         to: 'users#security_multifactor_challenge', via: [:put, :patch, :post]
    match '/security_multifactor_challenge',         to: 'users#security_multifactor_challenge', via: [:get]
 end

  get    '/go_back/:level',                                  to: 'application#go_back',                  as: 'go_back'

  resources :popup

  match '/github/set_repository/:id',                        to: 'github_accesses#set_repository',       via: [:get, :put, :patch, :post]
  match '/github/set_branch:id',                             to: 'github_accesses#set_branch',           via: [:get, :put, :patch, :post]
  match '/github/set_folder:id',                             to: 'github_accesses#set_folder',           via: [:get, :put, :patch, :post]
  match '/github/get_repositories',                          to: 'github_accesses#get_repositories',     via: [:get, :put, :patch, :post]
  match '/github/get_branches/:id',                          to: 'github_accesses#get_branches',         via: [:get, :put, :patch, :post]
  match '/github/get_folders/:repository/:id',               to: 'github_accesses#get_folders',          via: [:get, :put, :patch, :post]
  match '/github/get_files/:repository/:branch/:id',         to: 'github_accesses#get_files',            via: [:get, :put, :patch, :post]
  match '/github/get_file_contents/:repository/:branch/:id', to: 'github_accesses#get_file_contents',    via: [:get, :put, :patch, :post]

  resources :github_accesses

  # Gitlab Access
  match '/gitlab/set_repository/:id',                        to: 'gitlab_accesses#set_repository',       via: [:get, :put, :patch, :post]
  match '/gitlab/set_branch:id',                             to: 'gitlab_accesses#set_branch',           via: [:get, :put, :patch, :post]
  match '/gitlab/set_folder:id',                             to: 'gitlab_accesses#set_folder',           via: [:get, :put, :patch, :post]
  match '/gitlab/get_repositories',                          to: 'gitlab_accesses#get_repositories',     via: [:get, :put, :patch, :post]
  match '/gitlab/get_branches/:id',                          to: 'gitlab_accesses#get_branches',         via: [:get, :put, :patch, :post]
  match '/gitlab/get_folders/:repository/:id',               to: 'gitlab_accesses#get_folders',          via: [:get, :put, :patch, :post]
  match '/gitlab/get_files/:repository/:branch/:id',         to: 'gitlab_accesses#get_files',            via: [:get, :put, :patch, :post]
  match '/gitlab/get_file_contents/:repository/:branch/:id', to: 'gitlab_accesses#get_file_contents',    via: [:get, :put, :patch, :post]
  resources :gitlab_accesses

  # Duplicate and populate Global Templates
  match 'duplicate_global_templates',                to: 'templates#duplicate_global_templates', via: [:get, :put, :patch, :post]
  match 'populate_global_templates',                 to: 'templates#populate_global_templates',  via: [:get, :put, :patch, :post]

  match 'template_checklists',                       to: 'template_checklists#index',            via: [:get, :put, :patch, :post]
  match 'template_documents',                        to: 'template_documents#index',             via: [:get, :put, :patch, :post]

  # Static Page Routes
  root 'static_pages#home'
  get  'static_pages/home'
  get  'static_pages/help'
  get  'static_pages/about'
  get  '/help', to: 'static_pages#help'
  get  '/about', to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/privacy', to: 'static_pages#privacy'
  get  '/404', to: 'errors#not_found'
  get  '/422', to: 'errors#unacceptable'
  get  '/500', to: 'errors#internal_error'
  
  # Devise Routes
  as :user do
    get "/login",  to: "devise/sessions#new"
    get "/logout", to: "devise/sessions#destroy"
  end

  # Map major resources
  resources :projects do
    match '/filtered_problem_reports',                           to: 'problem_reports#filtered_index',                 via: [:get, :put, :patch, :post]
    match '/system_requirements/renumber',                       to: 'system_requirements#renumber',                   via: [:get, :put, :patch, :post]
    match '/system_requirements/export',                         to: 'system_requirements#export',                     via: [:get, :put, :patch, :post]
    match '/system_requirements/import',                         to: 'system_requirements#import',                     via: [:get, :put, :patch, :post]
    match '/system_requirements/allocation',                     to: 'requirements_tracing#system_allocation',         via: [:get, :put, :patch, :post]
    match '/system_requirements/unallocated',                    to: 'requirements_tracing#system_unallocated',        via: [:get, :put, :patch, :post]
    match '/review_status',                                      to: 'projects#review_status',                         via: [:get, :put, :patch, :post]

    resources :system_requirements do
      match '/mark_as_deleted',                                  to: 'system_requirements#mark_as_deleted',            via: [:get, :put, :patch, :post]
    end

    match '/model_files/renumber',                               to: 'model_files#renumber',                          via: [:get, :put, :patch, :post]
    match '/model_files/export',                                 to: 'model_files#export',                            via: [:get, :put, :patch, :post]
    match '/model_files/import',                                 to: 'model_files#import',                            via: [:get, :put, :patch, :post]
    match '/model_files/:id',                                    to: 'model_files#update',                            via: [:post]
  
    resources :model_files do
      match '/download',                                         to: 'model_files#download_file',                     via: [:get, :put, :patch, :post]
      match '/display',                                          to: 'model_files#display_file',                      via: [:get, :put, :patch, :post]
      match '/mark_as_deleted',                                  to: 'model_files#mark_as_deleted',                   via: [:get, :put, :patch, :post]
    end

    resources :items do
      match '/export',                                           to: 'items#export',                                   via: [:get, :put, :patch, :post]
    end

    match '/problem_reports/open',                               to: 'problem_reports#open_problem_reports_report',    via: [:get, :put, :patch, :post]
    match '/problem_reports/export',                             to: 'problem_reports#export',                         via: [:get, :put, :patch, :post]
    match '/problem_reports/import',                             to: 'problem_reports#import',                         via: [:get, :put, :patch, :post]

    resources :problem_reports do
      match '/mark_as_deleted',                                  to: 'problem_reports#mark_as_deleted',                via: [:get, :put, :patch, :post]
      match '/email_problem_report',                             to: 'problem_reports#email_problem_report',           via: [:get, :put, :patch, :post]
      match '/send_email',                                       to: 'problem_reports#send_email',                     via: [:get, :put, :patch, :post]
    end

    resources :archives do
      match '/view',                                             to: 'archives#view',                                  via: [:get, :put, :patch, :post]
      match '/unarchive',                                        to: 'archives#unarchive',                             via: [:get, :put, :patch, :post]
    end

    resources :requirements_baselines
  end

  match '/archives/show',                                        to: 'archives#make_archives_visible',                 via: [:get, :put, :patch, :post]

  resources :code_checkmarks do
    resources :code_checkmark_hits
  end

  resources :items do
    match '/high_level_requirements/renumber',                   to: 'high_level_requirements#renumber',               via: [:get, :put, :patch, :post]
    match '/high_level_requirements/export',                     to: 'high_level_requirements#export',                 via: [:get, :put, :patch, :post]
    match '/high_level_requirements/import',                     to: 'high_level_requirements#import',                 via: [:get, :put, :patch, :post]
    match '/high_level_requirements/:id',                        to: 'high_level_requirements#update',                 via: [:post]
    match '/requirements_tracing/export',                        to: 'requirements_tracing#export',                    via: [:get, :put, :patch, :post]

    resources :high_level_requirements do
      match '/mark_as_deleted',                                  to: 'high_level_requirements#mark_as_deleted',        via: [:get, :put, :patch, :post]
    end

    match '/low_level_requirements/renumber',                    to: 'low_level_requirements#renumber',                via: [:get, :put, :patch, :post]
    match '/low_level_requirements/export',                      to: 'low_level_requirements#export',                  via: [:get, :put, :patch, :post]
    match '/low_level_requirements/import',                      to: 'low_level_requirements#import',                  via: [:get, :put, :patch, :post]
    match '/low_level_requirements/:id',                         to: 'low_level_requirements#update',                  via: [:post]

    resources :low_level_requirements do
      match '/mark_as_deleted',                                  to: 'low_level_requirements#mark_as_deleted',         via: [:get, :put, :patch, :post]
    end

    match '/documents/select_documents',                         to: 'documents#select_documents',                     via: [:get, :put, :patch, :post]
    match '/documents/package_documents',                        to: 'documents#package_documents',                    via: [:get, :put, :patch, :post]
    match '/documents/get-pact-documents',                        to: 'documents#get_pact_documents',                  via: [:get, :put, :patch, :post]

    resources :documents do
      match '/upload_document',                                  to: 'documents#upload_document',                      via: [:get, :put, :patch, :post]
      match '/download_document',                                to: 'documents#download_document',                    via: [:get, :put, :patch, :post]
      match '/document_history',                                 to: 'documents#document_history',                     via: [:get, :put, :patch, :post]
      match '/display',                                          to: 'documents#display_file',                         via: [:get, :put, :patch, :post]
    end

    resources :reviews do
      match '/:email/checklist_items',                           to: 'reviews#checklist_items',                        via: :get
      match '/status',                                           to: 'reviews#status',                                 via: [:get, :put, :patch, :post]
    end

    match '/model_files/renumber',                               to: 'model_files#renumber',                          via: [:get, :put, :patch, :post]
    match '/model_files/export',                                 to: 'model_files#export',                            via: [:get, :put, :patch, :post]
    match '/model_files/import',                                 to: 'model_files#import',                            via: [:get, :put, :patch, :post]
    match '/model_files/:id',                                    to: 'model_files#update',                            via: [:post]

    resources :model_files do
      match '/download',                                         to: 'model_files#download_file',                     via: [:get, :put, :patch, :post]
      match '/display',                                          to: 'model_files#display_file',                      via: [:get, :put, :patch, :post]
      match '/mark_as_deleted',                                  to: 'model_files#mark_as_deleted',                   via: [:get, :put, :patch, :post]
    end

    match '/module_descriptions/export',                         to: 'module_descriptions#export',                    via: [:get, :put, :patch, :post]
    match '/module_descriptions/import',                         to: 'module_descriptions#import',                    via: [:get, :put, :patch, :post]
    match '/module_descriptions/renumber',                       to: 'module_descriptions#renumber',                  via: [:get, :put, :patch, :post]

    resources :module_descriptions do
      match '/mark_as_deleted',                                  to: 'module_descriptions#mark_as_deleted',            via: [:get, :put, :patch, :post]
    end

    match '/source_codes/analyze',                               to: 'source_codes#analyze',                           via: [:get, :put, :patch, :post]
    match '/source_codes/analysis',                              to: 'source_codes#analysis',                          via: [:get, :put, :patch, :post]
    match '/source_codes/instrument',                            to: 'source_codes#instrument',                        via: [:get, :put, :patch, :post]
    match '/source_codes/process_results',                       to: 'source_codes#process_results',                   via: [:get, :put, :patch, :post]
    match '/source_codes/profile',                               to: 'source_codes#profile',                           via: [:get, :put, :patch, :post]
    match '/source_codes/renumber',                              to: 'source_codes#renumber',                          via: [:get, :put, :patch, :post]
    match '/source_codes/export',                                to: 'source_codes#export',                            via: [:get, :put, :patch, :post]
    match '/source_codes/import',                                to: 'source_codes#import',                            via: [:get, :put, :patch, :post]
    match '/source_codes/scan_github',                           to: 'source_codes#scan_github',                       via: [:get, :put, :patch, :post]
    match '/source_codes/scan_gitlab',                           to: 'source_codes#scan_gitlab',                       via: [:get, :put, :patch, :post]
    match '/source_codes/select_github_files',                   to: 'source_codes#select_github_files',               via: [:get, :put, :patch, :post]
    match '/source_codes/select_gitlab_files',                   to: 'source_codes#select_gitlab_files',               via: [:get, :put, :patch, :post]
    match '/source_codes/generate',                              to: 'source_codes#generate',                          via: [:get, :put, :patch, :post]
    match '/source_codes/:id',                                   to: 'source_codes#update',                            via: [:post]
    match '/source_codes/diff',                                  to: 'source_codes#diff',                              via: [:get, :put, :patch, :post]
    match '/source_codes/zip',                                   to: 'source_codes#zip',                               via: [:get, :put, :patch, :post]
    match '/source_codes/package_source_codes',                  to: 'source_codes#package_source_codes',              via: [:get, :put, :patch, :post]

    resources :source_codes do
      match '/source_codes/process_results',                     to: 'source_codes#process_results',                   via: [:get, :put, :patch, :post]
      match '/download',                                         to: 'source_codes#download_file',                     via: [:get, :put, :patch, :post]
      match '/display',                                          to: 'source_codes#display_file',                      via: [:get, :put, :patch, :post]
      match '/mark_as_deleted',                                  to: 'source_codes#mark_as_deleted',                   via: [:get, :put, :patch, :post]
      match '/code_checkmarks',                                  to: 'code_checkmarks#index',                          via: [:get, :put, :patch, :post]
      match '/code_checkmark_hits',                              to: 'code_checkmark_hits#index',                      via: [:get, :put, :patch, :post]
      match '/code_checkmark_misses',                            to: 'code_checkmarks#index',                          via: [:get, :put, :patch, :post]
      match '/file_history',                                     to: 'source_codes#file_history',                      via: [:get, :put, :patch, :post]
    end

    match '/test_cases/renumber',                                to: 'test_cases#renumber',                            via: [:get, :put, :patch, :post]
    match '/test_cases/export',                                  to: 'test_cases#export',                              via: [:get, :put, :patch, :post]
    match '/test_cases/import',                                  to: 'test_cases#import',                              via: [:get, :put, :patch, :post]
    match '/test_cases/:id',                                     to: 'test_cases#update',                              via: [:post]

    resources :test_cases do
      match '/mark_as_deleted',                                  to: 'test_cases#mark_as_deleted',                     via: [:get, :put, :patch, :post]
    end

    match '/test_procedures/renumber',                           to: 'test_procedures#renumber',                       via: [:get, :put, :patch, :post]
    match '/test_procedures/export',                             to: 'test_procedures#export',                         via: [:get, :put, :patch, :post]
    match '/test_procedures/import',                             to: 'test_procedures#import',                         via: [:get, :put, :patch, :post]
    match '/test_procedures/select_github_files',                to: 'test_procedures#select_github_files',            via: [:get, :put, :patch, :post]
    match '/test_procedures/select_gitlab_files',                to: 'test_procedures#select_gitlab_files',            via: [:get, :put, :patch, :post]
    match '/test_procedures/:id',                                to: 'test_procedures#update',                         via: [:post]

    resources :test_procedures do
      match '/download',                                         to: 'test_procedures#download_file',                  via: [:get, :put, :patch, :post]
      match '/display',                                          to: 'test_procedures#display_file',                   via: [:get, :put, :patch, :post]
      match '/mark_as_deleted',                                  to: 'test_procedures#mark_as_deleted',                via: [:get, :put, :patch, :post]
    end

    # Requirements Tracing
    match '/requirements_tracing',                               to: 'requirements_tracing#index',                     via: [:get, :post]
    match '/requirements_tracing/specific',                      to: 'requirements_tracing#specific',                  via: [:get, :put, :patch, :post]
    match '/requirements_tracing/unlinked',                      to: 'requirements_tracing#unlinked',                  via: [:get, :put, :patch, :post]
    match '/requirements_tracing/unallocated',                   to: 'requirements_tracing#unallocated',               via: [:get, :put, :patch, :post]
    match '/requirements_tracing/derived',                       to: 'requirements_tracing#derived',                   via: [:get, :put, :patch, :post]

    # Templates
    match 'template_checklists/:review_type',                    to: 'items#get_checklists',                           via: [:get, :put, :patch, :post]

    resources :problem_reports
    resources :function_items
  end

  resources :documents do
    resources :document_comments
    resources :document_attachments
  end

  resources :problem_reports do
    resources :problem_report_histories

    resources :problem_report_attachments do
      match '/get_attachment',                to: 'problem_report_attachments#get_attachment', via: [:get, :put, :patch, :post]
    end
  end

  resources :checklist_items

  resources :reviews do
    resources :checklist_items do
      match 'remove',                         to: 'checklist_items#destroy',               via: [:get, :put, :patch]
    end
    resources :action_items

    resources :review_attachments do
      match '/download',                      to: 'review_attachments#download_file',       via: [:get, :put, :patch, :post]
      match '/display',                       to: 'review_attachments#display_file',        via: [:get, :put, :patch, :post]
    end

    # Fill Checklists
    match '/close',                           to: 'reviews#close',                         via: [:get, :put, :patch]

    # Fill Checklists
    match '/checklistfill',                   to: 'reviews#cl_fill',                       via: [:get, :put, :patch]
    # Remove Checklist items
    match '/checklistremoveall',              to: 'reviews#cl_removeall',                  via: [:get, :put, :patch]
    # Sign-in Sheet
    match '/sign-in',                         to: 'reviews#signin',                        via: [:get, :put, :patch]
    match '/save-sign-in',                    to: 'reviews#save_signin',                   via: [:get, :put, :patch]
    match '/select-attendees',                to: 'reviews#select_attendees',              via: [:get, :put, :patch]
    match '/sign-off',                        to: 'reviews#sign_off',                      via: [:get, :put, :patch]
    match '/assign-checklists',               to: 'reviews#assign_checklists',             via: [:get, :put, :patch]
    match '/renumber-checklist',              to: 'reviews#renumber_checklist',            via: [:get, :post, :put, :patch]
    match '/fill-in-checklist',               to: 'reviews#fill_in_checklist',             via: :get
    match '/fill-in-checklist',               to: 'reviews#submit_checklist',              via: [:put, :patch, :post]
    match '/consolidated-checklist',          to: 'reviews#consolidated_checklist',        via: [:get, :put, :patch]
    match '/export-consolidated-checklist',   to: 'reviews#export_consolidated_checklist', via: [:get, :post, :put, :patch]
    match '/checklist',                       to: 'reviews#checklist',                     via: [:get, :put, :patch]
    match '/export-checklist',                to: 'reviews#export_checklist',              via: [:get, :post, :put, :patch]
    match '/import-checklist',                to: 'reviews#import_checklist',              via: [:get, :post, :put, :patch]
  end

  # Data Export and Import
  match '/export', to: 'export#index', via: [:get, :put, :patch]
  get 'export/user', defaults: { format: :csv }
  get 'import/index'
  get '/import', to: 'import#index'
  resources :import

  resources :data_changes do
    get "undo", to: 'data_changes#undo'
    get "redo", to: 'data_changes#redo'
  end

  resources :change_sessions do
    get "undo", to: 'change_sessions#undo'
    get "redo", to: 'change_sessions#redo'
  end

  resources :templates do
    match 'export',                     to: 'templates#export',                     via: [:get, :put, :patch, :post]
    match 'import',                     to: 'templates#import',                     via: [:get, :put, :patch, :post]

    resources :template_checklists do
      match 'export',                    to: 'template_checklists#export',          via: [:get, :put, :patch, :post]
      match 'import',                    to: 'template_checklists#import',          via: [:get, :put, :patch, :post]
      resources :template_checklist_items
    end

    resources :template_documents do
      match 'duplicate',                 to: 'template_documents#duplicate',        via: [:get, :put, :patch, :post]
      match 'download',                  to: 'template_documents#download',         via: [:get, :put, :patch, :post]
    end
  end


  # JSON Web Token
  get 'jwt/auth' => 'jwt#auth'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
