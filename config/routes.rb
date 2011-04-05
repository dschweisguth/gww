GWW::Application.routes.draw do
  get 'autocomplete_person_username' => 'root#autocomplete_person_username', :as => :root_autocomplete_person_username
  get '/' => 'root#index', :as => :root
  get 'about' => 'root#about', :as => :root_about
  get 'bookmarklet' => 'root#bookmarklet', :as => :root_bookmarklet
  
  resources :score_reports, :only => [ :index, :show ]

  get 'people/find' => 'people#find', :as => :find_person
  get 'people/sorted-by/:sorted_by/order/:order' => 'people#index', :as => :people
  get 'people/:id/guesses' => 'people#guesses', :as => :person_guesses
  get 'people/:id/posts' => 'people#posts', :as => :person_posts
  get 'people/:id/map' => 'people#map', :as => :person_map
  get 'people/:id/comments/page/:page' => 'people#comments', :as => :person_comments
  resources :people, :only => [ :show ] do
    collection do
      get :nemeses
      get :top_guessers
    end
  end

  get 'photos/sorted-by/:sorted_by/order/:order/page/:page' => 'photos#index', :as => :photos
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

  get 'wheresies/:year' => 'wheresies#show', :as => :wheresies

  get 'bookmarklet/show' => 'bookmarklet#show', :as => :bookmarklet

  get 'admin' => 'admin/root#index', :as => :admin_root
  get 'admin/bookmarklet' => 'admin/root#bookmarklet', :as => :admin_root_bookmarklet

  get 'admin/photos/edit_in_gww' => 'admin/photos#edit_in_gww', :as => :edit_in_gww
  get 'admin/photos/autocomplete_person_username' => 'admin/photos#autocomplete_person_username', :as => :admin_photos_autocomplete_person_username
  post 'admin/photos/update_all_from_flickr' => 'admin/photos#update_all_from_flickr', :as => :update_all_from_flickr
  post 'admin/photos/update_statistics' => 'admin/photos#update_statistics', :as => :update_statistics
  post 'admin/photos/:id/change_game_status' => 'admin/photos#change_game_status', :as => :change_game_status
  post 'admin/photos/:id/add_selected_answer' => 'admin/photos#add_selected_answer', :as => :add_selected_answer
  post 'admin/photos/:id/add_entered_answer' => 'admin/photos#add_entered_answer', :as => :add_entered_answer
  post 'admin/photos/:id/remove_revelation' => 'admin/photos#remove_revelation', :as => :remove_revelation
  post 'admin/photos/:id/remove_guess' => 'admin/photos#remove_guess', :as => :remove_guess
  post 'admin/photos/:id/reload_comments' => 'admin/photos#reload_comments', :as => :reload_comments
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
