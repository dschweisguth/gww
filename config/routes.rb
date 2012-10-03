GWW::Application.routes.draw do
  get 'autocomplete_person_username' => 'root#autocomplete_person_username', :as => :root_autocomplete_person_username
  get '/' => 'root#index', :as => :root
  get 'about-auto-mapping' => 'root#about_auto_mapping', :as => 'root_about_auto_mapping'
  %w(about bookmarklet).each do |action|
    get action => "root##{action}", :as => "root_#{action}"
  end

  resources :score_reports, :only => [ :index, :show ]

  get 'people/find' => 'people#find', :as => :find_person
  get 'people/sorted-by/:sorted_by/order/:order' => 'people#index', :as => :people
  %w(guesses posts map map_json).each do |action|
    get "people/:id/#{action}" => "people##{action}", :as => "person_#{action}"
  end
  get 'people/:id/comments/page/:page' => 'people#comments', :as => :person_comments
  resources :people, :only => [ :show ] do
    get :nemeses, :top_guessers, :on => :collection
  end

  get 'photos/sorted-by/:sorted_by/order/:order/page/:page' => 'photos#index', :as => :photos
  resources :photos, :only => [ :show ] do
    get :map_popup, :on => :member
    get :map, :map_json, :unfound, :unfound_data, :on => :collection
  end
  # TODO Dave test
  get 'photos/search/*terms' => 'photos#search', :as => :search_photos
  get 'photos/search_data/*terms/page/:page' => 'photos#search_data'

  resources :guesses, :only => [] do
    get :longest_and_shortest, :on => :collection
  end

  resources :revelations, :only => [] do
    get :longest, :on => :collection
  end

  get 'wheresies/:year' => 'wheresies#show', :as => :wheresies

  get 'bookmarklet/show' => 'bookmarklet#show', :as => :bookmarklet

  get 'admin' => 'admin/root#index', :as => :admin_root
  %w(update_from_flickr calculate_statistics_and_maps).each do |action|
    post "admin/#{action}" => "admin/root##{action}", :as => action
  end
  get 'admin/bookmarklet' => 'admin/root#bookmarklet', :as => :admin_root_bookmarklet

  get 'admin/photos/edit_in_gww' => 'admin/photos#edit_in_gww', :as => :edit_in_gww
  get 'admin/photos/autocomplete_person_username' => 'admin/photos#autocomplete_person_username', :as => :admin_photos_autocomplete_person_username
  %w(change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess).each do |action|
    post "admin/photos/:id/#{action}" => "admin/photos##{action}", :as => action
  end
  post "admin/photos/:id/update_from_flickr" => "admin/photos#update_from_flickr", :as => 'update_photo_from_flickr'

  namespace :admin do
    resources :photos, :only => [ :edit, :destroy ] do
      get :unfound, :inaccessible, :multipoint, :on => :collection
    end

    resources :score_reports, :only => [ :index, :new, :create, :destroy ]

  end

end
