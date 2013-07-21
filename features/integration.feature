Feature: Integrate with other GSOC projects

  In order to leverage the data sharing and comprehension power of RDF
  I want to integrate my code with that of other GSOC students

  Scenario: Integrate with Ruby Mining
    Given a CSV generator
    When I provide the reference file spec/csv/moar_bacon.csv and the label "moar_bacon" and the options {dimensions:["producer","pricerange"]}
    And generate a turtle string from it
    Given a ARFF writer
    When I call its from_turtle method on the turtle string
    Then I should be able to cluster the result and print statistics