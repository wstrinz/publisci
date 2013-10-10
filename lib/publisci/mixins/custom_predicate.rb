module PubliSci
  module CustomPredicate
    def has(predicate, object)
      if object.is_a? Symbol
        obj = object
      else
        predicate = RDF::Resource(predicate) if RDF::Resource(predicate).valid?
        obj = RDF::Resource(object)
        obj = RDF::Literal(object) unless obj.valid?
      end
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
            if vv.is_a? Symbol

              deref = Prov.registry.values.map{|h|
                h[vv] if vv
              }.reject{|x| x==nil}
              raise "Unknown Element #{vv}" unless deref.size > 0
              vv = RDF::Resource(deref.first)
            end
            str << "\t#{pk} #{vv.to_base} ;\n"
          }
        }
      end
    end
  end
end