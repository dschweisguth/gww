describe Admin::PhotosController do
  %w(unfound inaccessible multipoint).each do |action|
    describe action do
      it { has_named_route? "#{action}_admin_photos", "/admin/photos/#{action}" }
      it { does route(:get, "/admin/photos/#{action}").to controller: 'admin/photos', action: action }
    end
  end

  describe 'edit' do
    it { has_named_route? :edit_admin_photo, 666, '/admin/photos/666/edit' }
    it { does route(:get, '/admin/photos/666/edit').to controller: 'admin/photos', action: 'edit', id: '666' }
  end

  %w(change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess).each do |action|
    describe action do
      it { has_named_route? action, 666, "/admin/photos/666/#{action}" }
      it { does route(:post, "/admin/photos/666/#{action}").to controller: 'admin/photos', action: action, id: '666' }
    end
  end

  describe 'update_photo_from_flickr' do
    it { has_named_route? 'update_photo_from_flickr', 666, "/admin/photos/666/update_from_flickr" }
    it { does route(:post, "/admin/photos/666/update_from_flickr").to controller: 'admin/photos', action: 'update_from_flickr', id: '666' }
  end

  describe 'destroy' do
    it { has_named_route? :admin_photo, 666, '/admin/photos/666' }
    it { does route(:delete, '/admin/photos/666').to controller: 'admin/photos', action: 'destroy', id: '666' }
  end

  describe 'edit_in_gww' do
    it { has_named_route? :edit_in_gww, '/admin/photos/edit_in_gww' }
    it { does route(:get, '/admin/photos/edit_in_gww').to controller: 'admin/photos', action: 'edit_in_gww' }
  end

end
