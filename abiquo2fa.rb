require "sinatra"
require "resque"
require "abiquo-api"
require "./model"
require "./tokenize"

class Abiquo2FA < Sinatra::Base

  get "/" do
    erb :login
  end

	post "/token/?" do
    begin
      $event = Event.new(:created_at => Time.now, :updated_at => Time.now, :username => params[:username], :email => params[:email], :ip_address => request.ip, :status => 'ENQUEUED')
      $event.save
    rescue => e
      puts e
    end
    begin
      Resque.enqueue(Tokenize, params[:username], params[:email],$event.event_id)
      erb :validate, :locals => { :event_id => $event.event_id }
    rescue
      "There was a problem generating validation token. Try again later!"
    end
	end

  post "/validate/?" do

  end

  get "/all" do
    Token.all.each do |t|
      puts t.inspect
    end
    'test'
  end

end