Feature: Receive metadata as user input or extract from data sources

  To generate clean provenance strings through a friendly interface
  I want to use a DSL for the PROV ontology

  Scenario: Generate based on example for w3.org
    Given the prov DSL string from file examples/primer.prov
    When I call Prov.run on it
    Then I should receive a provenance string

  Scenario: Generate from file
    Given the prov DSL string from file examples/prov_dsl.prov
    When I call Prov.run on it
    Then I should receive a provenance string