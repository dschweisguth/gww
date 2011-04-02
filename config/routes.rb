# TODO Dave refactor
GWW::Application.routes.draw do
  match '/auto_complete_for_person_username' => 'root#auto_complete_for_person_username', :via => :post
  match '/' => 'root#index', :as => :root, :via => :get
  match 'about' => 'root#about', :as => :root_about, :via => :get
  match 'bookmarklet' => 'root#bookmarklet', :as => :root_bookmarklet, :via => :get
  
  resources :score_reports, :only => [ :index, :show ]

  match 'people/find' => 'people#find', :as => :find_person, :via => :get
  match 'people/sorted-by/:sorted_by/order/:order' => 'people#index', :as => :people, :via => :get
  # TODO Dave remove after first score report after 3/21/2011
  match 'people/show/:id' => 'people#old_show', :via => :get
  match 'people/:id/guesses' => 'people#guesses', :as => :person_guesses, :via => :get
  match 'people/:id/posts' => 'people#posts', :as => :person_posts, :via => :get
  match 'people/:id/map' => 'people#map', :as => :person_map, :via => :get
  match 'people/:id/comments/page/:page' => 'people#comments', :as => :person_comments, :via => :get
  resources :people, :only => [ :show ] do
    collection do
      get :nemeses
      get :top_guessers
    end
  end

  match 'photos/sorted-by/:sorted_by/order/:order/page/:page' => 'photos#index', :as => :photos, :via => :get
  resources :photos, :only => [ :show ] do
    member do
      get :map_popup
    end
    collection do
      get :map
      get :unfound
      get :unfound_data
    end
  end

  resources :guesses, :only => [] do
    collection do
      get :longest_and_shortest
    end
  end

  resources :revelations, :only => [] do
    collection do
      get :longest
    end
  end

  match 'wheresies/:year' => 'wheresies#show', :as => :wheresies, :via => :get

  match 'bookmarklet/show' => 'bookmarklet#show', :as => :bookmarklet, :via => :get

  match 'admin' => 'admin/root#index', :as => :admin_root, :via => :get
  match 'admin/bookmarklet' => 'admin/root#bookmarklet', :as => :admin_root_bookmarklet, :via => :get

  match 'admin/photos/edit_in_gww' => 'admin/photos#edit_in_gww', :as => :edit_in_gww, :via => :get
  match '/admin/photos/auto_complete_for_person_username' => 'admin/photos#auto_complete_for_person_username', :via => :post
  match 'admin/photos/update_all_from_flickr' => 'admin/photos#update_all_from_flickr', :as => :update_all_from_flickr, :via => :post
  match 'admin/photos/update_statistics' => 'admin/photos#update_statistics', :as => :update_statistics, :via => :post
  match 'admin/photos/:id/change_game_status' => 'admin/photos#change_game_status', :as => :change_game_status, :via => :post
  match 'admin/photos/:id/add_selected_answer' => 'admin/photos#add_selected_answer', :as => :add_selected_answer, :via => :post
  match 'admin/photos/:id/add_entered_answer' => 'admin/photos#add_entered_answer', :as => :add_entered_answer, :via => :post
  match 'admin/photos/:id/remove_revelation' => 'admin/photos#remove_revelation', :as => :remove_revelation, :via => :post
  match 'admin/photos/:id/remove_guess' => 'admin/photos#remove_guess', :as => :remove_guess, :via => :post
  match 'admin/photos/:id/reload_comments' => 'admin/photos#reload_comments', :as => :reload_comments, :via => :post
  namespace :admin do
    resources :photos, :only => [ :edit, :destroy ] do
      collection do
	get :inaccessible
	get :multipoint
	get :unfound
      end
    end
    resources :score_reports, :only => [ :index, :new, :create, :destroy ]
  end

end
