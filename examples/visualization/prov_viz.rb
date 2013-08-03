require 'bio-publisci'
require 'graphviz'

def entity_node(label)
  ent = @g.add_nodes(label)
  ent.color = "#F3F781"
  ent.style = "filled"
  ent
end

def agent_node(label)
  ag = @g.add_nodes(label)
  ag.color = "#FE9A2E"
  ag.style = "filled"
	ag.shape = "box"
	ag
end

def activity_node(label)
	act = @g.add_nodes(label)
	act.color = "#5858FA"
	act.style = "filled"
	act.shape = "box"
	act
end

nodemap={}
@g = GraphViz.new(:G, type: :digraph)

# runner = PubliSci::Prov::Model::Entity
runner = PubliSci::Prov::DSL::Singleton.new
runner.instance_eval(IO.read('primer.prov'),'primer.prov')
repo = runner.to_repository
Spira.add_repository :default, repo

include PubliSci::Prov::Model

Entity.enum_for.to_a.map{|e|
  nodemap[e.subject]=entity_node(e.label)
}

Agent.enum_for.to_a.map{|agent|
  nodemap[agent.subject]=agent_node(agent.label)
}

Activity.enum_for.to_a.map{|act|
  nodemap[act.subject]=activity_node(act.label)
}

Entity.enum_for.to_a.map{|e|
  if e.wasAttributedTo.first
    agent_node = nodemap[Agent.for(e.wasAttributedTo.first).subject]
    @g.add_edges(nodemap[e.subject],agent_node).label="wasAttributedTo"
  end

  if e.wasGeneratedBy
    activity_node = nodemap[Activity.for(e.wasGeneratedBy).subject]
    @g.add_edges(nodemap[e.subject],activity_node).label="wasGeneratedBy"
  end
}

Activity.enum_for.to_a.map{|act|
  if act.generated.first
    entity_node = nodemap[Entity.for(act.generated.first).subject]
    @g.add_edges(nodemap[act.subject],entity_node).label="generated"
  end

  if act.used.first
    entity_node = nodemap[Entity.for(act.used.first).subject]
    @g.add_edges(nodemap[act.subject],entity_node).label="used"
  end
  # if act.wasGeneratedBy
  #   activity_node = nodemap[Activity.for(act.wasGeneratedBy).subject]
  #   @g.add_edges(nodemap[act.subject],activity_node).label="wasGeneratedBy"
  # end
}

# puts "#{Agent.for(Entity.first.wasAttributedTo.first)}"

# g = GraphViz.new(:G, type: :digraph)

# ent = Entity.first
# ag = Agent.for(ent.wasAttributedTo.first)

# ent_n = g.add_nodes(ent.label)
# ag_n = g.add_nodes(ag.label)

# g.add_edges(ent_n,ag_n).label="prov:wasAttributedTo"

@g.output(png: "out.png")
`eog out.png`