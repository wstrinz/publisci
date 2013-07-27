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
    And the source object {resource: 'http://example.org/software/R/var/ex', software:'http://r-project.org', process: 'spec/resource/example.Rhistory'}
    And the rdf dataset {resource:'http://example.org/data'}
    When I call its provenance method with the source object and the rdf object
    Then I should receive a metadata string

  Scenario: Generate organizational provenance information
    Given a class which includes the Metadata module
    And the source object {resource: 'http://example.org/software/R/var/ex', author: 'http://example.org/people/jrs', author_name: "J Random Scientist", organization: 'http://example.org/org/science', organization_name: "The League of Science" }
    And the rdf dataset {resource:'http://example.org/data', author: 'http://gsocsemantic.wordpress.com/me', author_name: "Will Strinz", organization: 'http://sciruby.com/'}
    When I call its provenance method with the source object and the rdf object
    Then I should receive a metadata string