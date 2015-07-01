require 'sinatra'
require 'sinatra/reloader'
require 'tilt/haml'
require 'open-uri'
# require 'open3'
require 'json'
require_relative 'helpers'

helpers Helpers


get '/' do
    haml :index, format: :html5, layout: :main_layout
end


post '/images/' do
    # sub = params[:subreddit]
    # score = params[:score]
    # sort = params[:sort]
    # "params were: #{sub}, #{score}, #{sort}."
    page_array = get_pages(params[:subreddit],  params[:sort], params[:howmany])

    @images = parse_pages(page_array)
    
    haml :images, format: :html5, layout: :main_layout
end