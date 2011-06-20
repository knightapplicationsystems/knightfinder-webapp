#knightfinder.rb
require 'sinatra/base'
require 'bundler/setup'
require 'sinatra/activerecord'
require 'json'
require 'geokit'

class Venue < ActiveRecord::Base
  validates_presence_of :name
  has_many :deals
  has_many :visits
  
  def ll
    "#{self.longditude},#{self.lattitude}"
  end
end

class Deal < ActiveRecord::Base
  belongs_to :venue
end

class Visit < ActiveRecord::Base
  belongs_to :venue
end





class KnightFinder < Sinatra::Base
  
  configure do
    Geokit::Geocoders::google = 'ABQIAAAA3u5SpqaF2DYRIsPQ7SUS7hTtwS2snXC5p7JJaiv_N14kY4e6ixTzc_jYNIKYYCenoUoNg0PNmLBWvg'
  end
  
  #------ Generic Web Interface ------

  get "/" do
    redirect "/login"
  end

  get "/login" do
    "Login Page"
    request.inspect
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

  # Expects "/api/venues?q=City" or "/api/venues?loc=45.6456677,0.567765". Will fail on anything else.
  get "/api/venues" do
    if params[:loc]
      "Finding by LonLat: #{params[:loc]}"
      #Calculate all venues within 50 miles.
      #Return 200 with JSON for all venues within 50 miles.
    elsif params[:q]
      "Finding by Query: #{params[:q]}"
      #Check for cities
      #Return JSON:   {cities : { Brighton, {...}}, { Brighteelm, {...}}}
      #               {venues : {...}}
      #Or return 404
    else
      status 400
    end 
  end

  # Returns deals for the given venue as JSON.
  get "/api/venue/:id/deals" do
    @deals = Venue.find(params[:id]).deals.where(:active => true)
    if @deals.count < 1
      status 404
      "No Deals Found"
    else
      status 200
      content_type :json
      @deals.to_json
    end
  end

  # Expects "longditude", "lattitude" and "city" as POSTDATA.
  post "/api/venue/:id" do
    @venue = Venue.find(params[:id])
    @venue.visits.new(  :request_uri  => request.env["REQUEST_URI"],
                        :remote_ip    => request.env["REMOTE_ADDR"],
                        :user_agent   => request.env["HTTP_USER_AGENT"],
                        :longditude   => params[:longditude],
                        :lattitude    => params[:lattitude],
                        :city         => params[:city])
    status 201
  end

  #------- NOT USED YET --------
  
  #These routes & methods are included to maintain CRUD completeness.
  
  get "/api/venue/:id" do
    status 200
    content_type :json
    Venue.find(params[:id]).to_json
  end

end