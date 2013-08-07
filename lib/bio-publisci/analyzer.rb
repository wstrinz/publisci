module PubliSci

  #handles analysis of R expression to extract properties and recognize potential
  #ambiguity
  module Analyzer
  	def dirty?(data)
  		if data.is_a? Hash
  			data.map{|k,v|
  				return true if dirty?(k) || dirty?(v)
  			}
  			false
  		elsif data.is_a? Array
  			data.map{|datum|
  				return true if dirty?(datum)
  			}
  		else
  			dirty_characters = [".",' ']
  			if data.to_s.scan(/./) & dirty_characters
  				true
  			else
  				false
  			end
  		end
  	end

  	def recommend_range(data)
  		classes = data.map{|d| d.class}
  		homogenous = classes.uniq.size == 1
  		if homogenous
  			if classes[0] == Fixnum
  				"xsd:int"
  			elsif classes[0] == Float
  				"xsd:double"
  			elsif classes[0] == String
  				recommend_range_strings(data)
  			else
  				:coded
  			end
  		else
  			:coded
  		end
  	end

  	def recommend_range_strings(data)
  		return "xsd:int" if data.all?{|d| Integer(d) rescue nil}
  		return "xsd:int" if data.all?{|d| Float(d) rescue nil}
  		:coded
  	end

  	def check_integrity(obs, dimensions, measures)
  		obs.map{|o|
  				raise "MissingValues for #{(dimensions | measures) - o.keys}" unless ((dimensions | measures) - o.keys).empty?
  				raise "UnknownProperty #{o.keys - (dimensions | measures)}" unless (o.keys - (dimensions | measures)).empty?
  		}
  	end
  end
end