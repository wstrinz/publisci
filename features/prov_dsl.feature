Feature: Receive metadata as user input or extract from data sources

  To generate clean provenance strings through a friendly interface
  I want to use a DSL for the PROV ontology

  Scenario: Generate from file
    Given the prov DSL string from file examples/prov_dsl.prov
    When I call Prov.run on it
    Then I should receive a provenance string