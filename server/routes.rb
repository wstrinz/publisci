class PubliSciServer < Sinatra::Base
  set :public_dir, File.dirname(__FILE__) + '/public'

  get "/" do
    redirect 'repository'
  end

  get "/query" do
    @repo = settings.repository
    @query = params[:query] || example_query()
    unless @repo
      flash[:notice] = "Need to Load a repository first!"

      redirect 'repository'
    end
    haml :query
  end
  
  post "/query.?:format?" do
    @repo = settings.repository

    unless @repo
      flash[:notice] = "Need to Load a repository first!"

      redirect 'repository'
    end

    @query = params[:query]
    @result = content_for(query_repository(params[:query]))

    content_response :query, @result
  end

  get "/dsl" do
    @repo = settings.repository
    @script = params[:script] || example_dsl()
    unless @repo
      flash[:notice] = "Need to Load a repository first!"

      redirect 'repository'
    end
    haml :dsl
  end

  post "/dsl" do
    @repo = settings.repository
    @script = params[:script]

    unless @repo
      flash[:notice] = "Need to Load a repository first!"

      redirect 'repository'
    end

    @result = content_for(load_dsl(@script))
    flash.now[:notice] = @result
    content_response :dsl, @result
  end

  get "/repository.?:format?" do
    redirect 'repository/new' unless settings.repository
    @repo = settings.repository

    content_response :repository, rdf_content_for(@repo)
  end

  get "/repository/new" do
    @repo = settings.repository

    haml :new_repository
  end

  post "/repository/new" do
    type = params[:repo_type]
    settings.sudo_pass = params[:sudo_pass] if params[:sudo_pass]
    uri = params[:repo_uri] if params[:repo_uri]

    @repo = create_repository(type,uri)
    settings.repository = @repo

    redirect '/repository'
  end

  get "/repository/import" do
    @repo = settings.repository
    redirect '/repository' unless @repo

    haml :import
  end

  post "/repository/import" do
    @repo = settings.repository
    redirect '/repository' unless @repo

    if params[:upload_file]
      type = File.extname(params[:upload_file][:filename])
      if type.size > 0
        type = type[1..-1].to_sym
      else
        raise "Unknown Type for file #{params[:upload_file][:filename]}"
      end
      @result = import_rdf(params[:upload_file][:tempfile], type)
    else
      @result = import_rdf(params[:rdf_string], params[:rdf_format])
    end
    flash.now[:notice] = @result
    content_response :import, content_for(@result)
  end

  get "/repository/dump.?:format?" do
    @repo = settings.repository
    redirect '/repository' unless @repo


    content_response(:dump, rdf_content_for(@repo))
  end

  get "/repository/clear" do
    clear_repository

    redirect '/'
  end
end