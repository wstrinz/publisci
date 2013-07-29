module Prov
  class Entity
    include Prov::Element

    def source(s=nil)
      if s
        (@sources ||= []) << s
      else
        @sources
      end
    end

    def generated_by(activity=nil)
      if activity
        @generated_by = activity
      else
        @generated_by
      end
    end

    def to_n3
      <<-EOF
<#{subject}> a prov:Entity ;
  prov:wasGeneratedBy <#{generated_by.subject}> ;
  rdfs:label "#{__label}" .

      EOF
    end

    def to_s
      subject
    end
  end
end