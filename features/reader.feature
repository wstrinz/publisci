Feature: generate RDF

	In order to test the generators
	I want to be able to create turtle strings from various objects

	Scenario: generate turtle RDF from a Dataframe
		Given a Dataframe generator
		When I provide an R dataframe and the label "mr"
			And generate a turtle string from it 
		Then the result should contain a "qb:dataSet"
			And the result should contain some "qb:Observation"s

	Scenario: generate turtle RDF from a CSV
		Given a CSV generator
		When I provide the reference file spec/csv/bacon.csv and the label "bacon"
			And generate a turtle string from it 
		Then the result should contain a "qb:dataSet"
			And the result should contain some "qb:Observation"s

	Scenario: generate turtle RDF from an ARFF file
		Given a ARFF generator
		When I provide the file resources/weather.numeric.arff
			And generate a turtle string from it 
		Then the result should contain a "qb:dataSet"
			And the result should contain some "qb:Observation"s