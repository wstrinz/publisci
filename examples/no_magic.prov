# Example using as little generation "magic" as possible, for execution
# as plain Ruby script.
#
# Run using "ruby no_magic.prov"

require 'publisci'
include PubliSci::Prov::DSL


# Subject and type for most elements can be set manually
agent :publisci, subject: 'http://gsocsemantic.wordpress.com/publisci', type: "software"
agent :R, subject: "http://r-project.org"
agent :sciruby, subject: "http://sciruby.com", type: "organization"

plan :R_steps, subject: "http://example.org/plan/R_steps", steps: "spec/resource/example.Rhistory"

agent :Will do
  # subject can be called within a block as well
  subject "http://gsocsemantic.wordpress.com/me"
  type "person"
  name "Will Strinz"
  on_behalf_of "http://sciruby.com"
end

# The wasGeneratedBy relationship is usually created automatically when an activitiy
#   is associated with an entity, but it can be specified manually
entity :triplified_example, subject: "http://example.org/dataset/ex", generated_by: :triplify

entity :original do
  generated_by :use_R
  subject "http://example.org/R/ex"
  source "./example.RData"

  # Custom predicates and objects can be used for flexibility and extensibility
  has "http://purl.org/dc/terms/title", "original data object"
end

activity :triplify do
  # Most methods will take either Symbols or Strings, and correctly handle
  #   resources vs literals
  subject "http://example.org/activity/triplify"
  generated "http://example.org/dataset/ex"
  associated_with :publisci
  used :original
end

activity :use_R do
  subject "http://example.org/activity/use_R"
  generated "http://example.org/R/ex"

  associated_with :R
  associated_with :Will
end

# Running a prov script using the gem executable will print the result, but
#   if you use the DSL you'll have to do it manually. You also read out to a file
#   or other method/object of course (eg "open('out.ttl','w'){|file| file.write generate_n3}")
puts generate_n3