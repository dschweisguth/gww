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

  Scenario: Player views map of all photos
    Given there is a photo mapped at 37.735697, -122.504264
    When I go to the photos map page
    Then I should see the photo on the initial map

    When I click on the photo's marker
    Then I should see the map popup

    When I zoom the map to 37.73, 37.74, -122.51, -122.50
    Then I should see the photo on the map zoomed to 37.73, 37.74, -122.51, -122.50

    When I zoom the map to 37.74, 37.75, -122.50, -122.49
    Then I should see the map zoomed to 37.74, 37.75, -122.50, -122.49 but no photos

  Scenario: David Gallagher's software lists unfound photos
    Given there is a Flickr update
    And there is a photo
    When I request the unfound data
    Then I should see that the data was updated when the Flickr update started
    And I should see data for the photo
