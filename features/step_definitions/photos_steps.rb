Given %r{^there is a photo added on "(\d+/\d+/\d+)" by "(.*?)"$} do |date, username|
  create :photo, dateadded: Date.parse_utc_time(date), person: create(:person, username: username)
end

Then /^I should see a link to each photo$/ do
  Photo.all.each do |photo|
    expect(page).to have_css(%Q(a[href="#{photo_path photo}"]))
  end
end

Then /^I should see a link to each photo's poster$/ do
  Photo.all.each do |photo|
    expect(page).to have_css(%Q(a[href="#{person_path photo.person}"]))
  end
end

And %r(^the photo added on "(\d+/\d+/\d+)" should appear before the photo added on "(\d+/\d+/\d+)"$) do |date1, date2|
  url1, url2 = [date1, date2].map do |date|
    photo_path Photo.where(dateadded: Date.parse_utc_time(date)).first
  end
  expect(page.body.index url1).to be < page.body.index(url2)
end

Then(/^the photo added by "([^"]*)" should appear before the photo added by "([^"]*)"$/) do |username1, username2|
  expect(page.body.index username1).to be < page.body.index(username2)
end

Given(/^there is a mapped photo$/) do
  @photo = create :mapped_photo
end

Then(/^I should see the photo on the map$/) do
  # Test that the JSON necessary to display the photo is on the page. TODO run Javascript and inspect the map.
  page_config = {
    api_key: google_maps_api_key,
    photos: {
      partial: false,
      bounds: MultiPhotoMapControllerSupport::INITIAL_MAP_BOUNDS.as_json,
      photos: [
        {
          id: @photo.id,
          latitude: @photo.latitude,
          longitude: @photo.longitude,
          color: Color::Yellow.scaled(0, 1, 0),
          symbol: '?'
        }
      ]
    }
  }
  expect(page.body).to include("GWW.config = #{page_config.to_json};")
end
