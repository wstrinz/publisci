Feature: Receive metadata as user input or extract from data sources

  In order to publish and share data about my datasets
  I want to be able to attach metadata

  Scenario: Attach basic DC Terms info
    Given a class which includes the Metadata module
    When I call its basic method with the hash {var: "example", title: "example dataset", creator: "Will Strinz", description: "an example dataset", date: "1-10-2010"}
    Then I should receive a metadata string

  Scenario: Auto Generate some fields
    Given a class which includes the Metadata module
    When I call its basic method with the hash {var: "example", title: "example dataset", description: "an example dataset"}
    Then I should receive a metadata string

  Scenario: Generate process information
    Given a class which includes the Metadata module
    When I call its provenance method with the hash {var: "example", software: {name: "R", process: 'spec/resource/example.Rhistory'}}
    Then I should receive a metadata string

  Scenario: Generate organizational provenance information
    Given a class which includes the Metadata module
    When I call its provenance method with the hash {var: "example", creator: "http://gsocsemantic.wordpress.com/me", organization: "http://sciruby.com/"}
    Then I should receive a metadata string