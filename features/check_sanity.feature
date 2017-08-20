Feature: Check sanity

  As a developer
  In order to ensure that existing records are valid
  I want to run 'rake db:check_sanity' and see which records are invalid

  Background:
    Given I have a rails app using 'active_sanity'

  Scenario: Check sanity on empty database
    When I run "rake db:check_sanity"
    Then I should see "Checking the following models: Category, Post, User"
    Then I should not see any invalid records

  Scenario: Check sanity on database with valid records
    Given the database contains a few valid records
    When I run "rake db:check_sanity"
    Then I should not see any invalid records

  Scenario: Check sanity on database with invalid records
    Given the database contains a few valid records
    And the first author's username is empty and the first post category_id is nil
    When I run "rake db:check_sanity"
    Then I should see the following invalid records:
      | User     | 1 | {:username=>["can't be blank", "is too short (minimum is 3 characters)"]} |
      | Post     | 1 | {:category=>["can't be blank"]} |

  Scenario: Check sanity on database with invalid records with ignored classes
    Given the database contains a few valid records
    And the first author's username is empty and the first post category_id is nil
    And the User class is ignored
    When I run "rake db:check_sanity"
    Then I should see "Checking the following models: Category, Post"
