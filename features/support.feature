Feature: Cucumber support code
  As a feature writer
  I want my Cucumber support code to be 100% covered and sometimes meaningfully tested by itself
  So that it doesn't distract me when I want to look at real coverage gaps and test failures

  Scenario: Developer views the HTML source of a page that is causing a feature to fail
    Given page-showing has been neutered
    Then show me the page

  Scenario: Developer views a screenshot of a page that is causing a feature to fail
    Given screenshotting has been neutered
    Then show me the screen

  Scenario: Developer neglects to stub calls to FlickrService out of a feature
    When I do something that calls FlickrService and forget to stub it out then it should explode
