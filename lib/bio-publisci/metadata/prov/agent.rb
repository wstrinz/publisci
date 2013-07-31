module PubliSci
module Prov
  class Agent
    include Prov::Element

    def type(t=nil)
      if t
        @type = t.to_sym
      else
        @type
      end
    end

    def type=(t)
      @type = t.to_sym
    end

    def name(name=nil)
      if name
        @name = name
      else
        @name
      end
    end

    def name=(name)
      @name = name
    end

    def organization(organization=nil)
      if organization
        @organization = organization
      elsif @organization.is_a? Symbol
        raise "UnknownAgent: #{@organization}" unless Prov.agents[@organization]
        @organization = Prov.agents[@organization]
      else
        @organization
      end
    end

    def organization=(organization)
      @organization = organization
    end

    def on_behalf_of(other_agent=nil)
      if other_agent
        @on_behalf_of = other_agent
      elsif @on_behalf_of.is_a? Symbol
        raise "UnknownAgent: #{@on_behalf_of}" unless Prov.agents.has_key?(@on_behalf_of)
        @on_behalf_of = Prov.agents[@on_behalf_of]
      else
        @on_behalf_of
      end

      @on_behalf_of
    end
    alias_method :worked_for, :on_behalf_of

    def to_n3
      str = "<#{subject}> a"
      if type
        case type.to_sym
        when :software
          str << " prov:SoftwareAgent ;\n"
        when :person
          str << " prov:Person ;\n"
        when :organization
          str << " prov:Organization ;\n"
        end
      else
        str << " prov:Agent ;\n"
      end

      if name
        if type && type.to_sym == :person
          str << "\tfoaf:givenName \"#{name}\" ;\n"
        else
          str << "\tfoaf:name \"#{name}\" ;\n"
        end
      end

      if on_behalf_of
        str << "\tprov:actedOnBehalfOf <#{on_behalf_of}> ;\n"
      end

      add_custom(str)

      str << "\trdfs:label \"#{__label}\" .\n\n"
    end

    def to_s
      subject
    end
  end
end
end