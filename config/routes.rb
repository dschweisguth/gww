ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'people' do |people|
    people.list_people 'people/list/sorted-by/:sorted_by/order/:order', :action => 'list'
    people.nemeses 'people/nemeses', :action => 'nemeses'
    people.show_person 'people/show/:id', :action => 'show'
    people.list_comments 'people/comments/:id/page/:page', :action => 'comments'
  end

  map.with_options :controller => 'photos' do |photos|
    photos.list_photos 'photos/list/sorted-by/:sorted_by/order/:order/page/:page', :action => 'list'
    photos.show_photo 'photos/show/:id', :action => 'show'
  end

  map.longest_and_shortest 'guesses/longest_and_shortest',
    :controller => 'guesses', :action => 'longest_and_shortest'

  map.resources :score_reports, :only => [ :index, :show ]

  map.wheresies 'wheresies/:year', :controller => 'wheresies', :action => 'show'

  map.namespace :admin do |admin|
    admin.resources :photos, :only => [ :edit, :destroy ], :collection => { :unfound => :get, :inaccessible => :get, :multipoint => :get }
    admin.resources :score_reports, :only => [ :index, :new, :create, :destroy ]
  end

  map.with_options :controller => 'admin/photos', :conditions => { :method => :post } do |photos|
    photos.update_photos 'admin/photos/update', :action => 'update'
    photos.update_photo_statistics 'admin/photos/update_statistics', :action => 'update_statistics'
    photos.change_game_status 'admin/photos/:id/change_game_status', :action => 'change_game_status'
    photos.add_selected_answer 'admin/photos/:id/add_selected_answer', :action => 'add_selected_answer'
    photos.add_entered_answer 'admin/photos/:id/add_entered_answer', :action => 'add_entered_answer'
    photos.remove_revelation 'admin/photos/:id/remove_revelation', :action => 'remove_revelation'
    photos.remove_guess 'admin/photos/:id/remove_guess', :action => 'remove_guess'
    photos.reload_comments 'admin/photos/:id/reload_comments', :action => 'reload_comments'
  end

  map.with_options :controller => 'admin/root' do |admin_root|
    admin_root.admin_root 'admin'
    admin_root.connect 'admin/:action'
  end

  map.with_options :controller => 'root' do |root|
    root.root
    root.connect ':action'
  end

  map.connect ':controller/:action/:id'

end
