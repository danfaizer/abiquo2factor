require "sinatra"
require "resque"
require "abiquo-api"
require "./token"
require "./tokenize"

class Abiquo2FA < Sinatra::Base

  get "/" do
    erb :login
  end

	post "/token/?" do
    begin
      Resque.enqueue(Tokenize, params[:username], params[:email])
      erb :authenticate
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