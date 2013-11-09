module PubliSci
  module Interactive
    #to be called by other classes if user input is required

    #take message, options, defaults. can be passed block to handle default as well
    def interact(message, default, options=nil)
      puts message + " (#{default})\n[#{options}]"
      str = gets.chomp
      if str.size > 0
        if options
          if str.split(',').all?{|s| Integer(s) rescue nil}
            str.split(',').map(&:to_i).map{|i| options[i]}
          else
            str.split(',').each{|s| raise "unkown selection #{s}" unless options.include? s.strip}
            str.split(',').map(&:strip)
          end
        else
          str
        end
      elsif block_given?
        yield str
      else
        default
      end
    end
  end
end
