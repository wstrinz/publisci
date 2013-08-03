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

@g = GraphViz.new(:G, type: :digraph)
g = @g

ent_n = entity_node("entity") #g.add_nodes("entity")
ag_n = activity_node("activity")

g.add_edges(ent_n,ag_n).label="attributed"

g.output(png: "out.png")
`eog out.png`