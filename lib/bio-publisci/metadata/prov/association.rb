module PubliSci
module Prov
  class Association
    include Prov::Element


    def __label
      # raise "MissingInternalLabel: no __label for #{self.inspect}" unless @__label
      @__label ||= Time.now.nsec.to_s(32)
    end

    def agent(agent=nil)
      basic_keyword(:agent,:agents,agent)
    end

    def had_plan(*args, &block)
      if block_given?
        p = Prov::Plan.new
        p.instance_eval(&block)
        p.__label=args[0]
        @plan = p
        Prov.register(args[0], p)
      elsif args.size == 0
        if @plan.is_a? Symbol
          raise "UnknownPlan: #{@plan}" unless Prov.plans[@plan]
          @plan = Prov.plans[@plan]
        end
        @plan
      elsif args.size == 1
        @plan = args[0]
      else
        name = args.shift
        args = Hash[*args]
        p = Prov::Plan.new

        p.__label=name
        p.subject args[:subject]
        (args.keys - [:subject]).map{|k|
          raise "Unkown plan setting #{k}" unless try_auto_set(p,k,args[k])
        }
        @plan = p
        Prov.register(name, p)
      end
    end
    alias_method :plan, :had_plan

    def to_n3
      str = "<#{subject}> a prov:Association ;\n"
      str << "\tprov:agent <#{agent}> ;\n"
      str << "\tprov:hadPlan <#{plan}> ;\n" if plan
      str[-2] = ".\n"
      str
    end

    def to_s
      subject
    end
  end
end
end