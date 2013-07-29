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
  end
end