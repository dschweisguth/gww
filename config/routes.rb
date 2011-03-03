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

  map.connect 'wheresies/:action', :controller => 'wheresies'

  map.edit_photo 'admin/photos/edit/:id', :controller => 'admin/photos', :action => 'edit'

  map.resources :score_reports, :path_prefix => '/admin', :controller => 'admin/score_reports'

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
