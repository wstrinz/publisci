module PubliSci

  class SADI_request
    def self.send_request(service, turtle)
      response = RestClient.post(service, turtle, content_type: 'text/rdf+n3', accept: 'text/rdf+n3')
      RDF::Repository.new << RDF::Turtle::Reader.new(response)
    end

    def self.fetch_async(service,turtle)
      gr = send_request(service,turtle)

      rdfs = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
      polls = RDF::Query.execute(gr) do
        pattern [:obj, rdfs.isDefinedBy, :def]
      end

      poll_time = {}
      polls.map(&:def).select{|res| res.to_s["?poll="]}.each{|poll_url|
        poll_time[poll_url.to_s] = Time.now
      }

      results = []
      until results.size == poll_time.keys.size
        poll_url = poll_time.sort_by{|k,v| v}.first.first
        t = Time.now

        if poll_time[poll_url] > t
          puts "no poll urls ready, sleeping #{poll_time[poll_url] - t}"
          sleep poll_time[poll_url] - t
        end

        result = poll(poll_url)
        if result.is_a? Fixnum
          puts "#{poll_url} Response not ready, waiting #{result}"
          poll_time[poll_url] = Time.now + result
        else
          results << result
        end
      end

      results
    end

    def self.poll(url)
      resp = RestClient.get(url, accept: 'text/rdf+n3'){ |response, request, result, &block|
        if [301, 302, 307].include? response.code
          wait = response.headers[:retry_after]
          if wait
            return wait.to_i
          else
            response.follow_redirection(request, result, &block)
          end
        else
          response.return!(request, result, &block)
        end
      }
      resp.body
    end

    def self.try_fetch(poll_url)
      puts "polling #{poll_url}"
      loop do
        result = poll(poll_url)
        if result.is_a? Fixnum
          return result
        else
          return RDF::Repository.new << RDF::Turtle::Reader.new(result)
        end
      end
    end
  end

  class PostProcessor


    def self.process(infile,outfile,pattern)

      tmp = Tempfile.new('annot_temp')
      open(infile).each_line{|line|
        if line[pattern]
          line.scan(pattern).each{|loc|
            line.sub!(pattern,yield(loc.first))
          }
          tmp.write(line)
        else
          tmp.write(line)
        end
      }

      FileUtils.copy(tmp.path,outfile)

      outfile
    end
  end
end