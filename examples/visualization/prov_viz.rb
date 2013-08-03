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

def generic_node(label)
  act = @g.add_nodes(label)
  # act.color = "#5858FA"
  # act.style = "filled"
  act.shape = "box"
  act
end

def make_edges(from_obj,to_class,predicate)
  # from_class.enum_for.to_a.map{|from_obj|
    raise "Unknown From Node: #{from_obj.subject}" unless @nodemap[from_obj.subject]
    relation = from_obj.send(predicate)
    if relation
      if relation.is_a? Array
        relation.map{|r|
        other = to_class.for(r)
        raise "Unknown To Node: #{other.subject}" unless @nodemap[other.subject]
          @g.add_edges(@nodemap[from_obj.subject],@nodemap[other.subject]).label=predicate.to_s
        }
      else
        other = to_class.for(relation)
        raise "Unknown To Node: #{other.subject}" unless @nodemap[other.subject]
        @g.add_edges(@nodemap[from_obj.subject],@nodemap[other.subject]).label=predicate.to_s
      end
    end
  # }
end

@nodemap={}
@g = GraphViz.new(:G, type: :digraph)
infile = ARGV[0] || 'primer.prov'
runner = PubliSci::Prov::DSL::Singleton.new
runner.instance_eval(IO.read(infile),infile)
repo = runner.to_repository
Spira.add_repository :default, repo

include PubliSci::Prov::Model

Entity.enum_for.to_a.map{|e|
  @nodemap[e.subject]=entity_node(e.label)
}

Agent.enum_for.to_a.map{|agent|
  @nodemap[agent.subject]=agent_node(agent.label)
}

Activity.enum_for.to_a.map{|act|
  @nodemap[act.subject]=activity_node(act.label)
}

Association.enum_for.to_a.map{|association|
  @nodemap[association.subject]=generic_node(association.label)
}

Plan.enum_for.to_a.map{|plan|
  @nodemap[plan.subject]=generic_node(plan.label)
}


# Derivation.enum_for.to_a.map{|deriv|
#   @nodemap[deriv.subject]=generic_node(deriv.label)
# }

Entity.enum_for.to_a.map{|e|
  attribs ={
    "wasAttributedTo" => Agent,
    "wasGeneratedBy" => Activity,
    "wasDerivedFrom" => Entity,
  }
  attribs.each{|predicate,range| make_edges(e,range,predicate)}
}

Activity.enum_for.to_a.map{|act|
  attribs ={
    "generated" => Entity,
    "used" => Entity,
    "wasAssociatedWith" => Agent,
    "qualifiedAssociation" => Agent,
  }
  attribs.each{|predicate,range| make_edges(act,range,predicate)}
}

Agent.enum_for.to_a.map{|agent|
  attribs = {
    "actedOnBehalfOf" => Agent
  }
  attribs.each{|predicate,range| make_edges(agent,range,predicate)}
}

Association.enum_for.to_a.map{|assoc|
  attribs ={
    "agent" => Agent,
    "hadPlan" => Plan
  }
  attribs.each{|predicate,range| make_edges(assoc,range,predicate)}
}

# Association.enum_for.to_a.map{|assoc|
#   attribs ={
#     "agent" => Agent
#     "hadPlan" => Plan
#   }
#   attribs.each{|predicate,range| make_edges(assoc,range,predicate)}
# }

# Derivation.enum_for.to_a.map{|assoc|
#   attribs ={
#     "agent" => Entity
#   }
#   attribs.each{|predicate,range| make_edges(assoc,range,predicate)}
# }

@g.output(png: "out.png")
begin `eog out.png` rescue nil end
