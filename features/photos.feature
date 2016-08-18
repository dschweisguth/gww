Feature: Photos
  As a player
  I want to list photos in various ways
  So that I can see the ones I'm interested in at the moment

  Scenario: Player lists photos
    Given there is a photo added on "1/1/16" by "username1"
    And there is a photo added on "1/2/16" by "username2"
    And I go to the photos page sorted by date-added
    Then I should see "2 photos"
    And I should see a link to each photo
    And I should see a link to each photo's poster
    And the photo added on "1/2/16" should appear before the photo added on "1/1/16"

    When I follow the "posted by" link
    Then the photo added by "username1" should appear before the photo added by "username2"

  @javascript
  Scenario: Player views map of all photos
    Given there is a mapped photo
    And I go to the photos map page
    Then I should see the photo on the map

