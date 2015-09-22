require 'rubygems'
require 'sinatra'
require_relative 'reddit-images'

set :environment, :production
set :run, false

run Sinatra::Application
