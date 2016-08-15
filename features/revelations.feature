Feature: Revelations
  As a player
  I want to know how long players commit to keeping track of their unfounds
  So I can have a good feeling that if something is unfound it's still there to be found

  Scenario: Player views revelations that were the longest to reveal
    Given there are 11 revelations all revealed at different times
    And there has been enough activity for the home page to be displayed without error
    When I go to the home page
    And I follow the "Longest-lived revelations" link
    Then I should see a link to revealed photo 1
    And I should see a link to revealed photo 10
    But I should not see a link to revealed photo 11
