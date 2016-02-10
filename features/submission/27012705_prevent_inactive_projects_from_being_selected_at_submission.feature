@submission @projects
Feature: The submissions page should only autosuggests active and approved projects

  Background:
    Given I am an "Manager" user logged in as "abc123"
    And I have an active study called "study A"
    Given I am visiting study "study A" homepage

  Scenario: Inactive and unapproved projects are not shown
    Given I have an "approved" project called "Project A"
    And I have an "unapproved" project called "Project B"
    And I have an inactive project called "Project C"
    When I follow "Create Submission"
    Then I should see the required select field "Project" with the option "Project A"
    Then I should see the required select field "Project" without the option "Project B"
    Then I should see the required select field "Project" without the option "Project C"

