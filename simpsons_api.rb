require 'sinatra'
require 'data_mapper'
require 'slim'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/simpsons.db")

$base_host = ""

class Simpson
  include DataMapper::Resource
  property :id,      Serial
  property :name,    String, :required => true
  property :dad_id,	 Integer
  property :mom_id,	 Integer

  def as_json(options = {})
    {
      id:   self.id, 
      name: self.name,
      uri:  $base_host+self.id.to_s
    }
  end
end
DataMapper.finalize



get '/' do
  $base_host = request.host_with_port + request.path_info
  @base_host = request.host_with_port + request.path_info
  @family = Simpson.all
  
  request.accept.each do |type|
      case type
        when 'text/html'
          @title = "The whole clan"
          halt erb :index

        when 'application/json', 'text/json'

#          halt @family.to_json
          halt erb :json_index, :layout => false

        when 'application/xml', 'text/xml'
#          halt @family.to_xml
          halt erb :xml_index, :layout => false

      end
    end
    error 406
end

get '/:person' do
  @person = Simpson.get params[:person]
  @title = @person.name

  if @person
    @dad = Simpson.get @person.dad_id 
    @mom = Simpson.get @person.mom_id 

    erb :person
  end
end



