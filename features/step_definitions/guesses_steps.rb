Given /^there are guesses made from 1 to (\d+) seconds after their photos were added to the group$/ do |n|
  now = Time.now.getutc

  # Create only 1 photo and guesser for speed at the cost of an unrealistic number of guesses for one photo
  photo = create :photo, dateadded: now
  guesser = create :person

  n.times { |i| create :guess, photo: photo, person: guesser, commented_at: now + i + 1 }
end
