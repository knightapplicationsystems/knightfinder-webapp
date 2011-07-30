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
  
  def self.active
    self.where(:active => true)
  end
  
  def active_deals
    self.deals.active
  end
  
  def ll
    "#{self.latitude}, #{self.longitude}"
  end
  
  def self.find_by_id(id)
    self.where(:id => id)[0]
  end
end

class Deal < ActiveRecord::Base
  belongs_to :venue
  
  def self.active
    self.where(:active => true)
  end
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


  #------ Venue Web Interface ------
  
  get "/:id" do
    # TODO: Build Dashboard Page
    @venue = Venue.find_by_id(params[:id])
    erb :show_venue
  end

  get "/:id/edit" do
    # TODO: Build Edit Venue Page
    @venue = Venue.find_by_id(params[:id])
    erb :edit_venue
  end

  put "/:id/" do
    puts "Firing PUT not POST"
    puts "UPDATING RECORD #{params[:id]}"
    @venue = Venue.find_by_id(params[:id])
    @venue.update_attributes(params[:id])
    redirect "#{params[:id]}"
  end
  
  post "/:id" do
    puts "Firing POST not PUT"
    # TODO: Build CREATE Record on Venue
    puts "UPDATING RECORD #{params[:id]}"
    @venue = Venue.find_by_id(params[:id])
    @venue.update_attributes(params[:id])
    redirect "#{params[:id]}"
  end

  delete "/:id" do
    # TODO: Build DELETE Record on Venue
  end

  #------ Deals Web Interface ------

  get "/:id/deals" do
    # TODO: Build Deals List Page or JSON (Fox AJAX)
    @venue = Venue.find_by_id(params[:id])
    @deals = @venue.deals
    erb :show_deals
  end
  
  get "/:id/deals/:id/edit" do
    # TODO: Build Edit Deals Page (or use partial somewehere else and scrap this route)
    "Render List of Deals for Venue #{params[:id]}"
  end

  post "/:id/deals" do
    # TODO: Build CREATE Record on Deal
  end

  put "/:id/deals/:deal_id" do
    # TODO: Build UPDATE Record on Deal
  end
  
  delete "/:id/deals/:deal_id" do
    # TODO: Build DELETE Record on Deal
  end

  #------ API ------
  
  # Expects "/api/venues?q=City" or "/api/venues?loc=45.6456677,0.567765&limit=50". Will fail with 400 on anything else.
  # ENSURE: Latitude then Londitude!
  
  get "/api/venues" do
    
    if params[:loc] && params[:limit]
      
      #Array to hold venues that match
      @venues = []

      location = params[:loc].split(",").each {|a| a.strip}
      limit = params[:limit].to_f/100
      
      # Set up min and max lat and lon values, based on limit.
      min_lat = (location[0].to_f - limit)
      min_lon = (location[1].to_f - limit)
      max_lat = (location[0].to_f + limit)
      max_lon = (location[1].to_f + limit)
      
      # If the venue falls within the limits, add to @venues.
      Venue.all.each do |venue|
        @venues << venue if ((venue.longitude.to_f > min_lon && venue.longitude.to_f < max_lon) && (venue.latitude.to_f > min_lat && venue.latitude.to_f < max_lat))
      end
      
      # REMOVED DUE TO EXCESSIVE CALLS TO GOOGLE... USING ABOVE HACKY THING INSTEAD.
      #
      # If the query is a location GeoCode the Lat/Long sent in the URL and set up an empty array.
      # Geocode each venue by Lat/Long and compare the distance to the location passed in the URL.
      # If it's within the limit (passed by URL), add the venue to @venues array.
      #
      # @current_location = Geokit::Geocoders::GoogleGeocoder.geocode(params[:loc])
      # Venue.all.each do |venue|
      #   geocoded_venue = Geokit::Geocoders::GoogleGeocoder.geocode(venue.ll)
      #   @venues << venue if geocoded_venue.distance_to(@current_location) < params[:limit].to_f
      # end
      
      # Return JSONified array or 404.
      if @venues.length > 0
        status 200
        content_type :json
        @venues.to_json
      else
        status 404
        "No Records Found"
      end
      
    elsif params[:q]
      
      # If the query is a search term, Find venues matching it by city or name, and group the city results by city.
      venues_by_city = Venue.where("city lIKE ?", "%#{params[:q]}%").group_by {|e| e.city }
      venues_by_name = Venue.where("name LIKE ?", "%#{params[:q]}%")
      
      # Set up the return hash.
      @result = {:city_results => venues_by_city,
                 :name_results => venues_by_name}
      
      # Return it as JSON only if it's not empty. Otherwise return a 404.
      if (venues_by_city.count > 0 || venues_by_name.count > 0)
        content_type :json
        @result.to_json
      else
        status 404
        "No Records Found"
      end
      
    else
      status 400
      "Bad Request"
    end 
  end

  # Returns deals for the given venue as JSON.
  get "/api/venue/:id/deals" do
    
    puts "Called Dealsk OK"
    @venue = Venue.find_by_id(params[:id])
    puts "Called venue OK"
    @deals = @venue.deals
    puts @deals.inspect
    
    # if @deals.length < 1
    #       status 404
    #       "No Deals Found"
    #     else
      status 200
    #  content_type :json
    #  @deals.to_json
    # end
  end

  # Expects "longitude", "latitude" and "city" as POSTDATA.
  post "/api/venue/:id/log" do
    
    @venue = Venue.find_by_id(params[:id])
    @visit = @venue.visits.new(  :request_uri  => request.env["REQUEST_URI"],
                        :remote_ip    => request.env["REMOTE_ADDR"],
                        :user_agent   => request.env["HTTP_USER_AGENT"],
                        :longitude   => params[:longitude],
                        :latitude    => params[:latitude],
                        :city         => params[:city])
                        
    if @visit.save!
      status 201
      "Record Created"
    else
      status 500
      "Internal Server Error - Failed to log visit"
    end
    
  end

  #------- NOT USED YET --------
  
  #These routes & methods are included to maintain CRUD completeness.
  get "/api/venue/:id" do
    status 200
    content_type :json
    Venue.find_by_id(params[:id]).to_json
  end

end