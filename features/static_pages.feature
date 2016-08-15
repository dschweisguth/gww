Feature: Static pages
  As a player
  I want to read additional information
  So I know what's going on

  Scenario: Player views about page
    Given there has been enough activity for the home page to be displayed without error
    When I go to the home page
    When I follow the "About GWW" link
    Then I should see a link "Tomas Apodaca" to "https://www.flickr.com/people/tma/"

  @javascript
  Scenario: Player views about auto mapping page
    Given there is a guessed photo
    When I go to the photo's page
    And I follow the "GWW can't tell where it is from the guess or revelation" link
    Then I should see "Here are some examples of comments that it does understand:" in a new window

  Scenario: Player views player bookmarklet page
    Given there has been enough activity for the home page to be displayed without error
    When I go to the home page
    And I follow the 'the "View in GWW" bookmarklet' link
    Then I should see 'To add "View in GWW" to your bookmarks,'
