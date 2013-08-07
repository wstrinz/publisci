module PubliSci
  class Prov
    class Role
      # attr_writer :comment

      include Prov::Element

      def comment(str=nil)
        if str
          @comment = str
        else
          @comment
        end
      end

      # def steps(steps=nil)
      #   if steps
      #     if File.exist? steps
      #       steps = Array[IO.read(steps).split("\n")]
      #     end
      #     @steps = Array[steps]
      #   else
      #     @steps
      #   end
      # end

      def to_n3
        str = "<#{subject}> a prov:Role ;\n"
        str << "\trdfs:comment \"#{comment}\" ;\n" if comment
        add_custom(str)

        str << "\trdfs:label \"#{__label}\" .\n\n"
      end

      def to_s
        subject
      end
    end
  end
end