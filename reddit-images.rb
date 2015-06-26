require 'sinatra'
require 'sinatra/reloader'


get '/' do
    haml :index, format: :html5
end


post '/images/' do
    sub = params[:subreddit]
    score = params[:score]
    sort = params[:sort]
    "params were: #{sub}, #{score}, #{sort}."
end