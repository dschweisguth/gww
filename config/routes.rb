ActionController::Routing::Routes.draw do |map|

  map.connect 'admin', :controller => 'admin/root'
  map.connect 'admin/:action', :controller => 'admin/root'

  map.root :controller => 'root'
  map.connect ':action', :controller => 'root', :action => 'bookmarklet'

  map.show_person 'people/show/:id', :controller => 'people', :action => 'show'

  map.show_photo 'photos/show/:id', :controller => 'photos', :action => 'show'
  map.edit_photo 'photos/edit/:id', :controller => 'photos', :action => 'edit'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
