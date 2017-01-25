require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/simpsons.db")

class Simpson
  include DataMapper::Resource
  property :id,      Serial
  property :name,    String, :required => true
  property :dad_id,	 Integer
  property :mom_id,	 Integer
end
DataMapper.finalize

helpers do
  def entity_uri( entity )
    "/api/simpsons/#{entity}"
  end
end

get '/' do
  redirect to '/api/simpsons/'
end

get '/api/simpsons/' do
  @family = Simpson.all

  request.accept.each do |type|
      case type
        when 'application/json', 'text/json'
#          halt @family.to_json
          halt erb :json_index, :layout => false

        when 'application/xml', 'text/xml'
#          halt @family.to_xml
          halt erb :xml_index, :layout => false

        else
          @title = "The whole clan"
          halt erb :index
      end
    end
    error 406
end

get '/api/simpsons/:person' do
  @person = Simpson.get params[:person]

  if @person
    @title = @person.name
    @dad = Simpson.get @person.dad_id
    @mom = Simpson.get @person.mom_id

    erb :person
  end
end
