Given /^page-showing has been neutered$/ do
  # noinspection RubyArgCount
  stub(self).save_and_open_page
end

Given /^screenshotting has been neutered$/ do
  # noinspection RubyArgCount
  stub(self).save_screenshot
end

When /^I do something that calls FlickrService and forget to stub it out then it should explode$/ do
  expect { FlickrUpdater.update_everything }.to raise_error RuntimeError
end
