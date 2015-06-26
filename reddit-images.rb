require 'sinatra'
require 'sinatra/reloader'
require 'tilt/haml'


get '/' do
    haml :index, format: :html5, layout: :main_layout
end


post '/images/' do
    # sub = params[:subreddit]
    # score = params[:score]
    # sort = params[:sort]
    # "params were: #{sub}, #{score}, #{sort}."
    haml :images, format: :html5, layout: :main_layout
end