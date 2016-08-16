Feature: Guesses
  As a player
  I want to see the photos that took the longest and shortest time to guess
  So that I can get motivated to find the oldest unfounds and guess new ones quickly

  Scenario: Player views longest and shortest guesses
    Given there has been enough activity for the home page to be displayed without error
    And there are guesses made from 1 to 21 seconds after their photos were added to the group
    When I go to the home page
    And I follow the "Longest and shortest-lived unfounds" link
    Then I should see "1 seconds"
    And I should see "10 seconds"
    But I should not see "11 seconds"
    But I should see "12 seconds"
    And I should see "21 seconds"
