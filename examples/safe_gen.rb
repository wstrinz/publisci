require 'bio-publisci'

str = IO.read(ARGV[0])
str.untaint
$SAFE=4
runner = PubliSci::Prov::DSL::Instance.new
puts runner.instance_eval(str,ARGV[0])
