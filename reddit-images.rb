require 'sinatra'
require 'sinatra/reloader'


get '/' do
    haml :index, format: :html5
end