Given /^page-showing has been neutered$/ do
  any_instance_of Capybara::Session, save_and_open_page: nil
end
