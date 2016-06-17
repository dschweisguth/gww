Given /^page-showing has been neutered$/ do
  allow(self).to receive(:save_and_open_page)
end

Given /^screenshotting has been neutered$/ do
  allow(self).to receive(:save_screenshot)
end

When /^I do something that calls FlickrService and forget to stub it out then it should explode$/ do
  expect { FlickrUpdateJob::Job.run }.to raise_error RuntimeError
end
