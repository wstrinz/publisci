Feature: load triples into a store

	In order to query and share data
	I want to be able load the output into a variety of store 

	Scenario: Use an RDF::Graph to store data
		Given a store of type graph
		When I call the stores add method with the turtle file spec/turtle/bacon and an RDF::Repository
		Then I should recieve a non-empty graph

	Scenario: Use 4store to store data
		Given a store of type fourstore
		When I call the stores add method with the turtle file spec/turtle/bacon and the graph name "test"
		Then I should receive an info string

	Scenario: Run queries on store
		Given a store of type fourstore
		When I call the query method using the text in file spec/queries/integrity/1.rq
		Then I should receive 0 results
		When I call the query method using the text in file resources/queries/test.rq
		Then I should receive 10 results

	Scenario: Run queries on graph based store
		Given a store of type graph
		When I call the stores add method with the turtle file spec/turtle/bacon and an RDF::Repository
		Then calling the query method using the text in file spec/queries/integrity/1.rq should return 0 results
		And calling the query method using the text in file resources/queries/test.rq should return 10 results
