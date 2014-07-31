Feature: Administer photos
  As an admin
  I want to find photos with new guesses and score them
  So that the guesser will get credit for their guess

  Background:
    Given there is a Flickr update
    And updating a photo from Flickr does nothing
    And getting a person's attributes from Flickr returns what we'd expect given what's in the database

  Scenario: Admin sets a photo to unconfirmed and then back to unfound
    Given there is a photo with a comment by another player
    When I go to the admin home page
    And I follow the "Unfound or unconfirmed photos" link
    And I follow the "Edit" link
    And I press the "unconfirmed" button
    Then I should see "This photo is unconfirmed."

    When I press the "unfound" button
    Then I should see "This photo is unfound."

  Scenario: Admin scores a comment as a guess
    Given there is a photo with a comment by another player
    When I go to the photo's edit page
    And I press the "Add this guess" button
    Then I should see that the photo was guessed by the commenter

  Scenario: Admin removes a guess
    Given there is a photo with a comment by another player
    When I go to the photo's edit page
    And I press the "Add this guess" button
    And I press the "Remove this guess" button
    Then I should see "This photo is unfound."

  Scenario: Admin removes a guess by setting the photo to unfound
    Given there is a photo with a comment by another player
    When I go to the photo's edit page
    And I press the "Add this guess" button
    And I press the "unfound" button
    Then I should see "This photo is unfound."

  Scenario: Admin scores a comment as a revelation
    Given there is a photo with a comment by the poster
    When I go to the photo's edit page
    And I press the "Accept this revelation" button
    Then I should see that the photo was revealed by the poster

  Scenario: Admin removes a revelation
    Given there is a photo with a comment by the poster
    When I go to the photo's edit page
    And I press the "Accept this revelation" button
    And I press the "Remove this revelation" button
    Then I should see "This photo is unfound."

  Scenario: Admin removes a revelation by setting the photo to unfound
    Given there is a photo with a comment by the poster
    When I go to the photo's edit page
    And I press the "Accept this revelation" button
    And I press the "unfound" button
    Then I should see "This photo is unfound."

  @javascript
  Scenario: Admin scores a comment as a guess credited to a different player
    Given there is a photo with a comment by another player
    And there is a third player
    When I go to the photo's edit page
    And I enter the third player's username
    And I press the "Add this guess" button
    Then I should see that the photo was guessed by the third player

  Scenario: Admin reveals a photo with custom text
    Given there is a photo with a comment by another player
    When I go to the photo's edit page
    And I fill in "answer_text" with "Because I said so"
    And I press the "Reveal or guess this photo with the following text:" button
    Then I should see that the photo was revealed by the poster with the text "Because I said so"

  Scenario: Admin scores a photo as a guess credited to a different player with custom text
    Given there is a photo with a comment by another player
    And there is a third player
    When I go to the photo's edit page
    And I enter the third player's username
    And I fill in "answer_text" with "Because I said so"
    And I press the "Reveal or guess this photo with the following text:" button
    Then I should see that the photo was guessed by the third player with the text "Because I said so"

  Scenario: Admin deletes a photo
    Given there is a photo
    When I go to the photo's edit page
    And I press the "Delete this photo" button
    Then I should be on the admin home page

    When I follow the "Unfound or unconfirmed photos" link
    Then I should not see any photos

  Scenario: Admin deletes a photo that has been deleted from Flickr
    Given there is an inaccessible photo
    And updating a photo from Flickr returns an error
    When I go to the admin inaccessible photos page
    And I follow the "Edit" link
    Then I should see the error

    When I press the "Delete this photo" button
    Then I should be on the admin home page

    When I follow the "Unfound or unconfirmed photos" link
    Then I should not see any photos
