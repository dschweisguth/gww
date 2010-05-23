ActionController::Routing::Routes.draw do |map|

  map.admin_root 'admin', :controller => 'admin/root'
  map.connect 'admin/:action', :controller => 'admin/root'
  map.connect 'admin/photos/:action/:id', :controller => 'admin/photos'
  map.connect 'admin/guesses/:action', :controller => 'admin/guesses'

  map.root :controller => 'root'
  map.connect ':action', :controller => 'root'

  map.list_people 'people/list/sorted-by/:sorted_by',
    :controller => 'people', :action => 'list'
  map.show_person 'people/show/:id', :controller => 'people', :action => 'show'
  map.connect 'people/comments/:id/page/:page',
    :controller => 'people', :action => 'comments'

  map.show_photo 'photos/show/:id', :controller => 'photos', :action => 'show'
  map.edit_photo 'admin/photos/edit/:id',
    :controller => 'admin/photos', :action => 'edit'
  map.connect 'photos/most_commented_on/page/:page',
    :controller => 'photos', :action => 'most_commented_on'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'

end
