Feature: Check sanity with db storage

  As a developer
  In order to ensure that existing records are valid
  I want to run 'rake db:check_sanity' to log invalid records in the db

  Background:
    Given I have a rails app using 'active_sanity' with db storage

  Scenario: Check sanity on empty database
    When I run "rake db:check_sanity"
    Then I should see "Checking the following models: Category, Post, User"
    Then the table "invalid_records" should be empty

  Scenario: Check sanity on database with valid records
    Given the database contains a few valid records
    When I run "rake db:check_sanity"
    Then the table "invalid_records" should be empty

  Scenario: Check sanity on database with invalid records
    Given the database contains a few valid records
    And the first author's username is empty and the first post category_id is nil
    When I run "rake db:check_sanity"
    Then the table "invalid_records" should contain:
      | User     | 1 | {:username=>["can't be blank", "is too short (minimum is 3 characters)"]} |
      | Post     | 1 | {:category=>["must exist", "can't be blank"]} |

  Scenario: Check sanity on database with invalid records now valid
    Given the database contains a few valid records
    And the first author's username is empty and the first post category_id is nil
    When I run "rake db:check_sanity"
    Then the table "invalid_records" should contain:
      | User     | 1 | {:username=>["can't be blank", "is too short (minimum is 3 characters)"]} |
      | Post     | 1 | {:category=>["must exist", "can't be blank"]} |

    Given the first author's username is "Greg"
    When I run "rake db:check_sanity"
    Then the table "invalid_records" should contain:
      | Post     | 1 | {:category=>["must exist", "can't be blank"]} |
    Then the table "invalid_records" should not contain errors for "User" "1"

  Scenario: Check sanity on database with invalid records that were invalid for different reasons earlier
    Given the database contains a few valid records
    And the first author's username is empty and the first post category_id is nil
    When I run "rake db:check_sanity"
    Then the table "invalid_records" should contain:
      | User     | 1 | {:username=>["can't be blank", "is too short (minimum is 3 characters)"]} |
      | Post     | 1 | {:category=>["must exist", "can't be blank"]} |

    Given the first post category is set
    And the first post title is empty
    When I run "rake db:check_sanity"
    Then the table "invalid_records" should contain:
      | User     | 1 | {:username=>["can't be blank", "is too short (minimum is 3 characters)"]} |
      | Post     | 1 | {:title=>["can't be blank"]} |
