module PubliSci
  module Prov
    class Configuration
      def defaults
        {
          output: :generate_n3,
          abbreviate: false,
          repository: :in_memory,
          repository_url: 'http://localhost:8080/'
        }
      end

      def output
        @output ||= defaults[:output]
      end

      def output=(output)
        @output = output
      end

      def abbreviate
        @abbreviate ||= defaults[:abbreviate]
      end

      def abbreviate=(abbreviate)
        @abbreviate = abbreviate
      end

      def repository
        @repository ||= defaults[:repository]
      end

      def repository=(repository)
        @repository = repository
      end

      def repository_url
        @repository_url ||= defaults[:repository_url]
      end

      def repository_url=(repository_url)
        @repository_url = repository_url
      end
    end
  end
end
