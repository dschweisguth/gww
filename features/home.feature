Feature: Home page
  As a player
  I want easy access to all of GWW's features and information from one place
  So I can find what I'm looking for and get back to guessing

  # See wheresies.feature for a test of the link to the Wheresies
  Scenario: Player views home page
    Given a Flickr update started at "2016/8/14 16:46" and is still running
    And there is a score report
    When I go to the home page
    Then I should see "The most recent update from Flickr began Sunday, August 14, 16:46"
    And I should see "and is still running"

  @javascript
  Scenario: Player finds a player by username
    Given there is a Flickr update
    And there is a score report
    And there is a player "abcdefgh"
    When I go to the home page
    And I autoselect "abcdefgh" from the "username" field
    And I press the "Find" button
    Then I should be on the player "abcdefgh"'s page
