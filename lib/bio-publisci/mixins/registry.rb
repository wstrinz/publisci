module PubliSci
  module Registry
    def self.register(name,object)
      # puts "register #{name} #{object} #{associations.size}"
      name = name.to_sym if name
      if object.is_a? Agent
        sub = :agents
      elsif object.is_a? Entity
        sub = :entities
      elsif object.is_a? Activity
        sub = :activities
      elsif object.is_a? Association
        sub = :associations
      elsif object.is_a? Plan
        sub = :plans
      else
        sub = object.class.to_s.split('::').last.downcase.to_sym
        # raise "UnknownElement: unkown object type for #{object}"
      end
      if name
        (registry[sub] ||= {})[name] = object
      else
        (registry[sub] ||= []) << object
      end
    end

    def self.registry
      @registry ||= {}
    end
  end
end