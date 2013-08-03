require 'bio-publisci'
require 'graphviz'

# runner = PubliSci::Prov::Model::Entity
runner = PubliSci::Prov::DSL::Singleton.new
runner.instance_eval(IO.read('primer.prov'),'primer.prov')
repo = runner.to_repository
Spira.add_repository :default, repo

include PubliSci::Prov::Model

# puts "#{Agent.for(Entity.first.wasAttributedTo.first)}"

g = GraphViz.new(:G, type: :digraph)

ent = Entity.first
ag = Agent.for(ent.wasAttributedTo.first)

ent_n = g.add_nodes(ent.label)
ag_n = g.add_nodes(ag.label)

g.add_edges(ent_n,ag_n).label="prov:wasAttributedTo"

g.output(png: "out.png")
`eog out.png`