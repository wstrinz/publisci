require 'graphviz'

def entity_node(label)
  ent = @g.add_nodes(label)
  ent.color = "#ddaa66"
  ent.style = "filled"
end

def agent_node(label)
  ag = @g.add_nodes(label)
  ag.color = "#ddaa66"
  ag.style = "filled"
end

@g = GraphViz.new(:G, type: :digraph)
g = @g

ent_n = g.add_nodes("entity")
ent_n.color = "#ddaa66"
ent_n.style = "filled"
ag_n = g.add_nodes("activity")
ag_n.shape = "box"

g.add_edges(ent_n,ag_n).label="attributed"

g.output(png: "out.png")
`eog out.png`