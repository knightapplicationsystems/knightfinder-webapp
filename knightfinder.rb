#foo.rb
require 'sinatra/base'
require 'bundler/setup'
require 'sinatra/activerecord'

class KnightFinder < Sinatra::Base
  
  #------ Generic Web Interface ------

  get "/" do
    redirect "/login"
  end

  get "/login" do
    "Login Page"
  end

  post "/login" do
    #Log User in and redirect to view, based on attached venue_id
    #Post data must contain login credentials
  end


  #------ Venues Web Interface ------
  
  get "/:id" do
    redirect "#{params[:id]}/view"
  end

  get "/:id/view" do
    "Render Dashboard Page for Venue #{params[:id]}"
  end

  get "/:id/edit" do
    "Render Edit Form for Venue #{params[:id]}"
  end

  post "/:id/edit" do
    #Perform UPDATE on Venue
    #Post data must contain fields to be updated.
    #Redirect to Dashboard
  end

  get "/:id/deals" do
    "Render List of Deals for Venue #{params[:id]}"
  end

  post "/:id/deals" do
    #Preform CREATE on Deals
    #Post data must contain venue_id and all other fields to be created.
    #Return new row as JSON
  end

  post "/:id/deals/:deal_id" do
    #Perform UPDATE on Deal
    #Post must contain deal_id and details to be updated.
    #Return updated row as JSON
  end


  #------ API ------

  get "/api/venues/:query" do
    #match against RegExp for LongLat
    #Return 200 with JSON for all venues within 50 miles: {venues : {...}}
    #Or Return 404
  end

  get "/api/venues/:query" do
    #Return JSON:   {cities : { Brighton, {...}}, { Brighteelm, {...}}}
    #               {venues : {...}}
    #Or return 404
  end

  get "/api/venue/:id/deals" do
    #Return JSON:   {..., Deals : {...}}
    #Or return 404
  end

  post "/api/venue/:id" do
    #Perform CREATE on Visits
    #Post Data must contain Remote IP, UA, City last Searched, Current Long/Lat
    #Return 201
  end

  #------- NOT USED YET --------
  
  #These routes & methods are included to maintain CRUD completeness.
  
  get "api/venue/:id" do
    #Return JSON {...} with 200
    #Or Return 404
  end

end