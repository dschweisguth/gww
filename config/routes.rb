ActionController::Routing::Routes.draw do |map|

  map.with_options :conditions => { :method => :get } do |user|

    user.with_options :controller => 'root' do |root|
      root.root
      %w{ about bookmarklet }.each do |action|
        root.send "root_#{action}", action, :action => action
      end
    end

    user.with_options :controller => 'people' do |people|
      people.find_person 'people/find', :action => 'find'
      people.people 'people/sorted-by/:sorted_by/order/:order', :action => 'index'
      people.connect 'people/show/:id', :action => 'old_show' # TODO Dave remove after first score report after 3/21/2011
      %w{ guesses posts }.each do |action|
        people.send "person_#{action}", "people/:id/#{action}", :action => action
      end
      people.person_comments 'people/:id/comments/page/:page', :action => 'comments'
    end

    user.photos 'photos/sorted-by/:sorted_by/order/:order/page/:page', :controller => 'photos', :action => 'index'

    user.wheresies 'wheresies/:year', :controller => 'wheresies', :action => 'show'

    user.bookmarklet 'bookmarklet/show', :controller => 'bookmarklet', :action => 'show'

  end
  map.connect '/auto_complete_for_person_username', :controller => 'root', :action => 'auto_complete_for_person_username', :conditions => { :method => :post }

  map.resources :score_reports, :only => [ :index, :show ]
  map.resources :people, :only => [ :show ], :collection => { :nemeses => :get, :top_guessers => :get }
  map.resources :photos, :only => [ :show ], :collection => { :unfound => :get, :unfound_data => :get }
  map.resources :guesses, :only => [], :collection => { :longest_and_shortest => :get }
  map.resources :revelations, :only => [], :collection => { :longest => :get }

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
      photos_with_post.connect '/admin/photos/auto_complete_for_person_username', :action => 'auto_complete_for_person_username'
    end

    photos.with_options :conditions => { :method => :post } do |photos_with_post|
      %w{ change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess reload_comments }.each do |action|
        photos_with_post.send action, "admin/photos/:id/#{action}", :action => action
      end
    end

  end

end
