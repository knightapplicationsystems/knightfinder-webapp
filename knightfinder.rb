#foo.rb
require "bundler/setup"
require 'sinatra/base'

class KnightFinder < Sinatra::Base
  get "/" do
    @ip = request.env['REMOTE_ADDR'].split(',').first
    "Your IP is: #{@ip}. Cool huh?"
  end
end