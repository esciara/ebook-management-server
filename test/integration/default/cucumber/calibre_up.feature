Feature: The Calibre server is up

  In order to make sure that Calibre has been installed and runs
  As a developer
  I want to access Calibre's home page

  Scenario: Developer accesses the home page
    Given the url of Calibre's home page
    When a web user browses to the url
    Then the connection should be successful
    Then the page status should be OK
    Then the page should have the title "..:: calibre library ::.. "