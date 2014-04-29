Given /^there is a photo with an unscored guess$/ do
  @comment = create :comment
end

Then /^I should see that the photo was guessed by the guesser$/ do
  guesses = @comment.photo.guesses
  guesses.count.should == 1
  guess = guesses.first
  tds = page.find('table').all 'td'
  tds[0].text.should == guess.person.username
  tds[2].text.should == guess.comment_text
end
