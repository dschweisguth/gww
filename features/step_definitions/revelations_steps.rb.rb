Given /^there are (\d+) revelations all revealed at different times$/ do |n|
  n = n.to_i
  n.times { create :revelation, added_at: Time.local(2011, 1, 1, 0, 1, n) }
end

Then /^I should see a link to revealed photo (\d+)$/ do |i|
  photo = revealed_photo i
  expect(page).to have_css(%Q(a[href="#{photo_path photo}"]))
end

Then /^I should not see a link to revealed photo (\d+)$/ do |i|
  photo = revealed_photo i
  expect(page).not_to have_css(%Q(a[href="#{photo_path photo}"]))
end

def revealed_photo(i)
  Revelation.order(:added_at).offset(i.to_i - 1).includes(photo: :person).limit(1).first.photo
end
