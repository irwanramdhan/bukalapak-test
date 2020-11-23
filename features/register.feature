Feature: Register as Bukalapak user

  Scenario: Register as new user
    Given user is on bukalapak register page
    When user fill the register form
    Then system should redirect user to home page