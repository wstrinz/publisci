module PubliSci
module Prov
  class Association
    def subject(sub=nil)
      if sub
        @subject = sub
      else
        @subject ||= "#{Prov.base_url}/assoc/#{Time.now.nsec.to_s(32)}"
      end
    end

    def agent(agent=nil)
      if agent
        # agent = Prov.agents[agent.to_sym] if agent.is_a?(String) || agent.is_a?(Symbol)
        # raise "UnkownAgent #{ag}" unless agent
        # puts "Warning: overwriting agent #{@agent.subject}" if @agent
        @agent = agent
      elsif @agent.is_a? Symbol
        @agent = Prov.agents[@agent]
      else
        @agent
      end
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
          @plan = Prov.plans[@plan]
        end
        @plan
      elsif args.size == 1
        if args[0].is_a? Symbol
          raise "UnknownPlan: #{args[0]}" unless Prov.plans[args[0]]
          @plan = Prov.plans[args[0]]
        else
          @plan = args[0]
        end
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