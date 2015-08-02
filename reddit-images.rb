require 'sinatra'
require 'sinatra/reloader'
require 'tilt/haml'
require 'open-uri'
require 'json'
require_relative 'helpers'

# file containing API key is ignored by git.
API_KEY = 'Client-ID ' + `cat ./imgur_api_key`

helpers Helpers


get '/' do
    haml :index, format: :html5, layout: :main_layout
end

post '/images/' do
    page_array = get_pages(params[:subreddit],  params[:sort], params[:howmany])

    @images = parse_pages(page_array, params[:score])
    
    haml :images, format: :html5, layout: :main_layout
end

get '/*' do
    redirect to('/'), 303
end