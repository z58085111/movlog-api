require 'sinatra'
require 'econfig'

#configure based on environment
class MovlogAPI < Sinatra::Base
  extend Econfig::Shortcut

  API_VER = 'api/v0.1'

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)
    Skyscanner::SkyscannerApi.config.update(api_key: config.SKY_API_KEY)
    Airbnb::AirbnbApi.config.update(client_id: config.AIRBNB_CLIENT_ID)
  end

  get '/?' do
    "MovlogAPI latest version endpoints are at: /#{API_VER}/"
  end
end