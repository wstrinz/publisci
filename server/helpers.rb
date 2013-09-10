class PubliSciServer < Sinatra::Base

  helpers do
    def ba
      settings.foo
    end
  end
end