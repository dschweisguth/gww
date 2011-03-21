ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'root', :conditions => { :method => :get } do |root|
    root.root
    %w{ about bookmarklet }.each do |action|
      root.send "root_#{action}", action, :action => action
    end
  end

  map.resources :score_reports, :only => [ :index, :show ]

  map.with_options :controller => 'people' do |people|
    people.find_person 'people/find', :action => 'find'
    people.people 'people/sorted-by/:sorted_by/order/:order', :action => 'index'
    people.nemeses 'people/nemeses', :action => 'nemeses'
    people.show_person 'people/show/:id', :action => 'show'
    people.list_comments 'people/comments/:id/page/:page', :action => 'comments'
  end

  map.resources :photos, :only => [ :show ], :collection => { :unfound => :get, :unfound_data => :get }
  map.with_options :controller => 'photos', :conditions => { :method => :get } do |photos|
    photos.photos 'photos/sorted-by/:sorted_by/order/:order/page/:page', :action => 'index'
  end

  map.resources :guesses, :only => [], :collection => { :longest_and_shortest => :get }

  map.resources :revelations, :only => [], :collection => { :longest => :get }

  map.wheresies 'wheresies/:year', :controller => 'wheresies', :action => 'show'

  map.bookmarklet 'bookmarklet/show', :controller => 'bookmarklet', :action => 'show'

  map.with_options :controller => 'admin/root', :conditions => { :method => :get } do |admin_root|
    admin_root.admin_root 'admin'
    admin_root.admin_root_bookmarklet 'admin/bookmarklet', :action => 'bookmarklet'
  end

  map.namespace :admin do |admin|
    admin.resources :photos, :only => [ :edit, :destroy ], :collection => { :unfound => :get, :inaccessible => :get, :multipoint => :get }
    admin.resources :score_reports, :only => [ :index, :new, :create, :destroy ]
  end

  map.with_options :controller => 'admin/photos' do |photos|

    photos.edit_in_gww 'admin/photos/edit_in_gww', :action => 'edit_in_gww', :conditions => { :method => :get }

    photos.with_options :conditions => { :method => :post } do |photos_with_post|
      %w{ update_all_from_flickr update_statistics }.each do |action|
        photos_with_post.send action, "admin/photos/#{action}", :action => action
      end
    end

    photos.with_options :conditions => { :method => :post } do |photos_with_post|
      %w{ change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess reload_comments }.each do |action|
        photos_with_post.send action, "admin/photos/:id/#{action}", :action => action
      end
    end

  end

  map.connect ':controller/:action/:id'

end
