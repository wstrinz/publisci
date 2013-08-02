module PubliSci
  module Prov
    class Usage
      include Prov::Element

      def __label
        @__label ||= Time.now.nsec.to_s(32)
      end

      def entity(entity=nil)
        basic_keyword(:entity,:entities,entity)
      end

      def had_role(*args, &block)
        if block_given?
          p = Prov::Role.new
          p.instance_eval(&block)
          p.__label=args[0]
          @role = p
          # puts p.class
          Prov.register(args[0], p)
        elsif args.size == 0
          if @role.is_a? Symbol
            raise "UnknownRole: #{@role}" unless (Prov.registry[:role]||={})[@role]
            @role = Prov.registry[:role][@role]
          end
          @role
        elsif args.size == 1
          unless (Prov.registry[:role]||={})[args[0]]
            p = Prov::Role.new
            p.__label=args[0]
            @role = p
            Prov.register(args[0], p)
          end
        else
          name = args.shift
          args = Hash[*args]
          p = Prov::Role.new

          p.__label=name
          p.subject args[:subject]
          (args.keys - [:subject]).map{|k|
            raise "Unkown Role setting #{k}" unless try_auto_set(p,k,args[k])
          }
          @role = p
          Prov.register(name, p)
        end
      end
      alias_method :role, :had_role

      def to_n3
        str = "<#{subject}> a prov:Usage ;\n"
        str << "\tprov:entity <#{entity}> ;\n"
        str << "\tprov:hadRole <#{had_role}> ;\n" if had_role
        str[-2] = ".\n"
        str
      end

      def to_s
        subject
      end
    end
  end
end