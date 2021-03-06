module PubliSci
class Prov
  class Plan
    include Prov::Element

    def steps(steps=nil)
      if steps
        if File.exist? steps
          steps = Array[IO.read(steps).split("\n")]
        end
        @steps = Array[steps]
      else
        @steps
      end
    end

    def to_n3
      str = "<#{subject}> a prov:Plan ;\n"
      if steps
        str << "\trdfs:comment (\"#{steps.join('" "')}\") ;\n"
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