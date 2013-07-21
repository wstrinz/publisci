Feature: create generators

	In order to check that objects conform to a common interface
	I want to be able to call a generate method on various classes 

	Scenario: create a Dataframe generator
		Given a Dataframe generator
		Then I should be able to call its generate_n3 method

	Scenario: create a CSV generator
		Given a CSV generator
		Then I should be able to call its generate_n3 method	

	Scenario: create a RMatrix generator
		Given a RMatrix generator
		Then I should be able to call its generate_n3 method

	Scenario: create a Cross generator
		Given a Cross generator
		Then I should be able to call its generate_n3 method	

	Scenario: create a BigCross generator
		Given a BigCross generator
		Then I should be able to call its generate_n3 method	

