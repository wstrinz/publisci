module Prov
  module Element
    def subject(s=nil)
      if s
        if s.is_a? Symbol
          raise "subject generation coming soon!"
        else
          @subject = s
        end
      else
        @subject ||= generate_subject
      end
    end

    def subject=(s)
      @subject = s
    end

    def __label=(l)
      @__label = l
    end

    def __label
      raise "MissingInternalLabel: no __label for #{self.inspect}" unless @__label
      @__label
    end

    private
    def generate_subject
      # puts self.class == Prov::Activity
      case self
      when Agent
        "#{Prov.base_url}/agent/#{__label}"
      when Entity
        "#{Prov.base_url}/entity/#{__label}"
      when Activity
        "#{Prov.base_url}/activity/#{__label}"
      else
        raise "MissingSubject: No automatic subject generation for #{self}"
      end
    end
  end

  def self.register(name,object)
    name = name.to_sym if name
    if object.is_a? Agent
      sub = :agents
    elsif object.is_a? Entity
      sub = :entities
    elsif object.is_a? Activity
      sub = :activities
    elsif object.is_a? Association
      sub = :associations
    else
      raise "UnknownElement: unkown object type for #{object}"
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

  def self.run(string)
    if File.exists? string
      Prov::DSL::Singleton.new.instance_eval(IO.read(string),string)
    else
      Prov::DSL::Singleton.new.instance_eval(string)
    end
  end

  def self.agents
    registry[:agents] ||= {}
  end

  def self.entities
    registry[:entities] ||= {}
  end

  def self.activities
    registry[:activities] ||= {}
  end

  def self.associations
    registry[:associations] ||= {}
  end

  def self.base_url
    @base_url ||= "http://rqtl.org/ns"
  end

  def self.base_url=(url)
    @base_url = url
  end
end
