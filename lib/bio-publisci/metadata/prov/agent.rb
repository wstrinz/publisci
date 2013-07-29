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
  end
end