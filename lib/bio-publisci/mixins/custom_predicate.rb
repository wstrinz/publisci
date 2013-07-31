module PubliSci
  module CustomPredicate
    def has(predicate, object)
      predicate = RDF::Resource(predicate) if RDF::Resource(predicate).valid?
      obj = RDF::Resource(object)
      obj = RDF::Literal(object) unless obj.valid?
      ((@custom ||= {})[predicate] ||= []) << obj
    end
    alias_method :set, :has

    def custom
      @custom
    end

    def add_custom(str)
      if custom
        custom.map{|k,v|
          pk = k.respond_to?(:to_base) ? k.to_base : k
          v.map{|vv|
            str << "\t#{pk} #{vv.to_base} ;\n"
          }
        }
      end
    end
  end
end