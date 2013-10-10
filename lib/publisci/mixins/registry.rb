module PubliSci
  module Registry
    def register(name,object)
      # puts "register #{name} #{object} #{associations.size}"
      name = name.to_sym if name
      if symbol_for(object)
        sub = symbol_for(object)
      else
        sub = object.class.to_s.split('::').last.downcase.to_sym
      end
      if name
        (registry[sub] ||= {})[name] = object
      else
        (registry[sub] ||= []) << object
      end
    end

    def registry
      @registry ||= {}
    end

    #should be overridden
    def symbol_for(object)
      false
    end
  end
end