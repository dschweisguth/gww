require 'will_paginate/array'

describe PhotosController do
  describe '#map_popup' do
    it "renders the partial" do
      photo = build_stubbed :photos_photo, dateadded: Time.local(2011)
      allow(photo).to receive(:guesses).and_return([])
      allow(photo).to receive(:revelation).and_return(nil)
      allow(PhotosPhoto).to receive(:find_with_associations).with(photo.id).and_return(photo)
      get :map_popup, id: photo.id

      expect(response).to be_success
      link = top_node.find %Q(a[href="#{photo_path(photo)}"])
      expect(link).to have_css %Q(img[src="#{url_for_flickr_image(photo, 't')}"])
      expect(response.body).to have_link photo.person.username, href: person_path(photo.person)
      expect(response.body).to include ', January  1, 2011.'
      expect(response.body).not_to include 'Guessed by'
      expect(response.body).not_to include 'Revealed'

    end

    it "displays guesses" do
      photo = build_stubbed :photos_photo, dateadded: Time.local(2011)
      guess = build_stubbed :guess, photo: photo, commented_at: Time.local(2011, 2)
      allow(photo).to receive(:guesses).and_return([guess])
      allow(photo).to receive(:revelation).and_return(nil)
      allow(PhotosPhoto).to receive(:find_with_associations).with(photo.id).and_return(photo)
      get :map_popup, id: photo.id

      expect(response.body).to have_link guess.person.username, href: person_path(guess.person)
      expect(response.body).to include ', February  1, 2011.'
      expect(response.body).not_to include 'Revealed'

    end

    it "displays a revelation" do
      photo = build_stubbed :photos_photo, dateadded: Time.local(2011)
      allow(photo).to receive(:guesses).and_return([])
      allow(photo).to receive(:revelation).and_return(build_stubbed :revelation, photo: photo, commented_at: Time.local(2011, 2))
      allow(PhotosPhoto).to receive(:find_with_associations).with(photo.id).and_return(photo)
      get :map_popup, id: photo.id

      expect(response.body).not_to include 'Guessed by'
      expect(response.body).to include 'Revealed February  1, 2011.'

    end

  end

  describe '#search' do
    it "redirects away from an invalid and/or noncanonical URI to a canonical one" do
      get :search, segments: 'did'
      expect(response).to redirect_to search_photos_path
    end
  end

  describe '#search_data' do
    it "redirects away from an invalid and/or noncanonical URI to a canonical one" do
      get :search_data
      expect(response).to redirect_to search_photos_data_path('page/1')
    end
  end

  describe '#show' do
    it "renders the page" do
      photo = build_stubbed :photos_photo, datetaken: Time.local(2009), dateadded: Time.local(2010), other_user_comments: 11, views: 22, faves: 33
      guess = build_stubbed :guess, photo: photo
      allow(photo).to receive(:guesses).and_return([guess])
      allow(PhotosPhoto).to receive(:find).with(photo.id).and_return(photo)
      comment = build_stubbed :comment, photo: photo
      allow(photo).to receive(:comments).and_return([comment])
      allow(photo).to receive(:human_tags).and_return([])
      allow(photo).to receive(:machine_tags).and_return([])
      get :show, id: photo.id

      expect(response).to be_success
      link = top_node.find %Q(a[href="#{url_for_flickr_photo_in_pool(photo)}"])
      expect(link).to have_css %Q(img[src="#{url_for_flickr_image(photo, 'z')}"])
      expect(response.body).to include photo.title
      expect(response.body).to include photo.description
      expect(response.body).to include 'This photo is unfound.'
      table = top_node.find 'table'
      expect(table).to have_css 'td', text: guess.person.username
      expect(table).to have_css 'td', text: guess.comment_text
      expect(response.body).to have_css 'strong', text: comment.username
      expect(response.body).to include comment.comment_text
      expect(response.body).to include 'This photo was taken at 12:00 AM, January  1, 2009'
      expect(response.body).to have_css %Q(a[href="#{url_for_flickr_photos photo.person}archives/date-taken/2009/01/01/"]), text: 'archives'
      expect(response.body).to have_css %Q(a[href="#{search_photos_path "did/activity/done-by/#{photo.person.username}/from-date/12-31-2008/to-date/1-2-2009"}"]), text: 'activity'
      expect(response.body).to include 'It was added to the group at 12:00 AM, January  1, 2010.'
      expect(response.body).to include "This photo hasn't been found or revealed yet"
      expect(response.body).not_to include 'It was mapped by the photographer'
      expect(response.body).not_to include 'It was auto-mapped'
      expect(response.body).to include '11 comments'
      expect(response.body).to include '22 views'
      expect(response.body).to include '33 faves'
      expect(response.body).not_to include 'GWW.config'
      expect(response.body).not_to include 'Tags'
      expect(response.body).not_to include 'Machine tags'

    end

    it "handles a photo without datetaken" do
      photo = build_stubbed :photos_photo, dateadded: Time.local(2010), other_user_comments: 11, views: 22, faves: 33
      guess = build_stubbed :guess, photo: photo
      allow(photo).to receive(:guesses).and_return([guess])
      allow(PhotosPhoto).to receive(:find).with(photo.id).and_return(photo)
      comment = build_stubbed :comment, photo: photo
      allow(photo).to receive(:comments).and_return([comment])
      allow(photo).to receive(:human_tags).and_return([])
      allow(photo).to receive(:machine_tags).and_return([])
      get :show, id: photo.id

      expect(response).to be_success
      expect(response.body).to include 'This photo was added to the group at 12:00 AM, January  1, 2010.'

    end

    it "includes a map if the photo is mapped" do
      photo = build_stubbed :photos_photo, latitude: 37, longitude: -122, accuracy: 12
      allow(photo).to receive(:comments).and_return([])
      allow(photo).to receive(:guesses).and_return([])
      allow(photo).to receive(:revelation).and_return(nil)
      allow(photo).to receive(:human_tags).and_return([])
      allow(photo).to receive(:machine_tags).and_return([])
      allow(PhotosPhoto).to receive(:find).with(photo.id).and_return(photo)
      oldest = build_stubbed :photos_photo, dateadded: 1.day.ago
      allow(PhotosPhoto).to receive(:oldest).and_return(oldest)
      get :show, id: photo.id

      expect(response).to be_success
      expect(response.body).to include 'It was mapped by the photographer'
      expect(response.body).not_to include "This photo hasn't been found or revealed yet"
      expect(response.body).not_to include 'It was auto-mapped'
      expect(response.body).to have_css '#map'
      page_config = controller.with_google_maps_api_key(
        photo: {
          id: photo.id,
          latitude: photo.latitude.to_s,
          longitude: photo.longitude.to_s,
          color: Color::Yellow.scaled(0, 0, 0),
          symbol: '?'
        }
      )
      expect(response.body).to match(/GWW\.config = #{Regexp.escape page_config.to_json};/)

    end

    it "includes a map if the photo is auto-mapped" do
      photo = build_stubbed :photos_photo, inferred_latitude: 37, inferred_longitude: -122
      allow(photo).to receive(:comments).and_return([])
      allow(photo).to receive(:guesses).and_return([])
      allow(photo).to receive(:revelation).and_return(nil)
      allow(photo).to receive(:human_tags).and_return([])
      allow(photo).to receive(:machine_tags).and_return([])
      allow(PhotosPhoto).to receive(:find).with(photo.id).and_return(photo)
      oldest = build_stubbed :photos_photo, dateadded: 1.day.ago
      allow(PhotosPhoto).to receive(:oldest).and_return(oldest)
      get :show, id: photo.id

      expect(response).to be_success
      expect(response.body).to include 'It was auto-mapped'
      expect(response.body).not_to include "This photo hasn't been found or revealed yet"
      expect(response.body).not_to include 'It was mapped by the photographer'
      expect(response.body).to have_css '#map'
      page_config = controller.with_google_maps_api_key(
        photo: {
          id: photo.id,
          latitude: photo.inferred_latitude.to_s,
          longitude: photo.inferred_longitude.to_s,
          color: Color::Yellow.scaled(0, 0, 0),
          symbol: '?'
        }
      )
      expect(response.body).to match(/GWW\.config = #{Regexp.escape page_config.to_json};/)

    end

    it "displays tags" do
      photo = build_stubbed :photos_photo
      allow(photo).to receive(:comments).and_return([])
      allow(photo).to receive(:guesses).and_return([])
      allow(photo).to receive(:revelation).and_return(nil)
      allow(photo).to(receive(:human_tags)) do
        [build_stubbed(:tag, raw: 'Tag 2'), build_stubbed(:tag, raw: 'Tag 1')]
      end
      allow(photo).to(receive(:machine_tags)) do
        [build_stubbed(:tag, raw: 'Machine tag 2'), build_stubbed(:tag, raw: 'Machine tag 1')]
      end
      allow(PhotosPhoto).to receive(:find).with(photo.id).and_return(photo)
      get :show, id: photo.id

      expect(response.body).to match(/Tags.*Tag 2.*Tag 1/m)
      expect(response.body).to match(/Machine tags.*Machine tag 2.*Machine tag 1/m)

    end

    it "styles a foundinSF or unfoundinSF tag differently if it doesn't match the photo" do
      photo = build_stubbed :photos_photo
      allow(photo).to receive(:comments).and_return([])
      allow(photo).to receive(:guesses).and_return([])
      allow(photo).to receive(:revelation).and_return(nil)
      allow(photo).to receive(:human_tags).and_return([build_stubbed(:tag, raw: 'foundinSF')])
      allow(photo).to receive(:machine_tags).and_return([])
      allow(PhotosPhoto).to receive(:find).with(photo.id).and_return(photo)
      get :show, id: photo.id

      expect(response.body).to have_css 'li.incorrect'

    end

  end

end
