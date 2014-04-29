Feature: Wheresies
  As a player
  I want to see objective statistics for the past year
  So that I can nominate other players for or award them a coveted Wheresie

  Scenario: Player views wheresies page
    Given scores were reported this year
    And there is a player "rookie" with no guesses from previous years
    And the player "rookie" scored 2 points this year
    And the player "rookie" posted 4 photos this year
    And there is a player "veteran" with a guess from a previous year
    And the player "veteran" scored 3 points this year
    And the player "veteran" posted 5 photos this year
    And a player "viewiest" posted a photo with 10 views
    And a player "faviest" posted a photo with 11 faves
    And a player "commentiest" posted a photo with a comment
    And a player "longest" guessed a photo after 3 years
    And a player "fastest" guessed a photo after 1 second
    When I go to this year's wheresies page
    Then the headline should say that the results are preliminary
    And the player "rookie" should be first on the rookies' most-points list with 2 points
    And the player "rookie" should be first on the rookies' most-posts list with 4 posts
    And the player "veteran" should be first on the veterans' most-points list with 3 points
    And the player "veteran" should be first on the veterans' most-posts list with 5 posts
    And the player "viewiest" should be first on the most-viewed list with 10 views
    And the player "faviest" should be first on the most-faved list with 11 faves
    And the player "commentiest" should be first on the most-commented list with 1 comment
    And the player "longest" should be first on the longest-lasting list with a photo guessed after 3 years
    And the player "fastest" should be first on the fastest-guessed list with a photo guessed after 1 second
