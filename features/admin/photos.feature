Feature: Administer photos
  As an admin
  I want to find photos with new guesses and score them
  So that the guesser will get credit for their guess

  Scenario: Admin scores a correct guess
    Given there is a Flickr update
    And there is a photo with an unscored guess
    When I go to the admin home page
    And I follow the "Unfound or unconfirmed photos" link
    And I follow the "Edit" link
    And I press the "Add this guess" button
    Then I should see that the photo was guessed by the guesser
