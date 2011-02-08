ActionController::Routing::Routes.draw do |map|

  map.admin_root 'admin', :controller => 'admin/root'
  map.connect 'admin/:action', :controller => 'admin/root'
  map.connect 'admin/photos/:action/:id', :controller => 'admin/photos'

  map.connect 'wheresies/:action', :controller => 'wheresies'

  map.root :controller => 'root'
  map.connect ':action', :controller => 'root'

  map.list_people 'people/list/sorted-by/:sorted_by/order/:order',
    :controller => 'people', :action => 'list'
  map.show_person 'people/show/:id', :controller => 'people', :action => 'show'
  map.list_comments 'people/comments/:id/page/:page',
    :controller => 'people', :action => 'comments'

  map.list_photos 'photos/list/sorted-by/:sorted_by/order/:order/page/:page',
    :controller => 'photos', :action => 'list'
  map.show_photo 'photos/show/:id', :controller => 'photos', :action => 'show'
  map.edit_photo 'admin/photos/edit/:id',
    :controller => 'admin/photos', :action => 'edit'

  map.longest_and_shortest 'guesses/longest_and_shortest',
    :controller => 'guesses', :action => 'longest_and_shortest'

  map.connect ':controller/:action/:id'

end
