Given /^page-showing has been neutered$/ do
  stub(self).save_and_open_page
end

Given /^screenshotting has been neutered$/ do
  stub(self).save_screenshot
end
