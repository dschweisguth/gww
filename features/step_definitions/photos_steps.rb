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

Then /^the photo added by "([^"]*)" should appear before the photo added by "([^"]*)"$/ do |username1, username2|
  expect(page.body.index username1).to be < page.body.index(username2)
end

Given /^there is a photo mapped at (\d+\.\d+), (-?\d+\.\d+)$/ do |latitude, longitude|
  @photo = create :mapped_photo, latitude: latitude, longitude: longitude
end

Then /^I should see the photo on the initial map$/ do
  # Test that the JSON necessary to display the photo is on the page. TODO run Javascript and inspect the map.
  expect(page.body).to include("GWW.config = #{page_config_json MultiPhotoMapControllerSupport::INITIAL_MAP_BOUNDS, [@photo]};")
end

When /^I click on the photo's marker$/ do
  visit map_popup_photo_path(@photo)
end

Then /^I should see the map popup$/ do
  expect(page).to have_css(%Q(a[href="#{photo_path @photo}"]))
end

When /^I zoom the map to (\d+\.\d+), (\d+\.\d+), (-?\d+\.\d+), (-?\d+\.\d+)$/ do |min_lat, max_lat, min_long, max_long|
  get map_json_photos_path, sw: "#{min_lat},#{min_long}", ne: "#{max_lat},#{max_long}"
end

Then /^I should see the photo on the map zoomed to (\d+\.\d+), (\d+\.\d+), (-?\d+\.\d+), (-?\d+\.\d+)$/ do |min_lat, max_lat, min_long, max_long|
  # Test that the JSON necessary to display the photo is in the response. TODO run Javascript and inspect the map.
  page_config_json = page_config_json bounds_json_data(min_lat, max_lat, min_long, max_long), [@photo]
  expect(last_response.body).to eq(page_config_json)
end

Then /^I should see the map zoomed to (\d+\.\d+), (\d+\.\d+), (-?\d+\.\d+), (-?\d+\.\d+) but no photos$/ do |min_lat, max_lat, min_long, max_long|
  page_config_json = page_config_json bounds_json_data(min_lat, max_lat, min_long, max_long), []
  expect(last_response.body).to eq(page_config_json)
end

def bounds_json_data(min_lat, max_lat, min_long, max_long)
  Bounds.new(*[min_lat, max_lat, min_long, max_long].map(&:to_f))
end

def page_config_json(bounds, photos)
  {
    api_key: ENV['GOOGLE_MAPS_API_KEY'],
    photos: {
      partial: false,
      bounds: bounds.as_json,
      photos: photos.map do |photo|
        {
          id: photo.id,
          latitude: photo.latitude,
          longitude: photo.longitude,
          color: Color::Yellow.scaled(0, 1, 0),
          symbol: '?'
        }
      end
    }
  }.to_json
end

When(/^I request the unfound data$/) do
  get unfound_data_photos_path
end

Then /^I should see that the data was updated when the Flickr update started$/ do
  expect(top_data_node).to have_css(%Q(photos[updated_at="#{@flickr_update.created_at.to_i}"]))
end

Then /^I should see data for the photo$/ do
  expect(top_data_node).to have_css("photo[posted_by=#{@photo.person.username}]")
end

def top_data_node
  Capybara.string(last_response.body)
end
