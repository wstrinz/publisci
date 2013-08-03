require 'bio-publisci'

str = IO.read(ARGV[0])
str.untaint
$SAFE=4
runner = PubliSci::Prov::DSL::Singleton.new
puts runner.instance_eval(str,ARGV[0])
