Given /^page-showing has been neutered$/ do
  stub(self).save_and_open_page
end

Given /^screenshotting has been neutered$/ do
  stub(self).save_screenshot
end

When /^I do something that calls FlickrService and forget to stub it out then it should explode$/ do
  expect { Photo.update_all_from_flickr }.to raise_error RuntimeError
end
