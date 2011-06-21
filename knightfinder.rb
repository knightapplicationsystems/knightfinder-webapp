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
    "#{self.longditude},#{self.lattitude}"
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
  
  # Expects "/api/venues?q=City" or "/api/venues?loc=45.6456677,0.567765". Will fail with 400 on anything else.
  get "/api/venues" do
    if params[:loc]
      
      # If the query is a location...
      "Finding by LonLat: #{params[:loc].split('?')[0]}"
      # Calculate all venues within 50 miles.
      # Return 200 with JSON for all venues within 50 miles.
      
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
    
    @deals = Venue.find(params[:id]).active_deals
    
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
  post "/api/venue/:id/log" do
    
    @venue = Venue.find(params[:id])
    @visit = @venue.visits.new(  :request_uri  => request.env["REQUEST_URI"],
                        :remote_ip    => request.env["REMOTE_ADDR"],
                        :user_agent   => request.env["HTTP_USER_AGENT"],
                        :longditude   => params[:longditude],
                        :lattitude    => params[:lattitude],
                        :city         => params[:city])
                        
    if @visit.save!
      status 201
    else
      status 500
    end
    
  end

  #------- NOT USED YET --------
  
  #These routes & methods are included to maintain CRUD completeness.
  get "/api/venue/:id" do
    status 200
    content_type :json
    Venue.find(params[:id]).to_json
  end

end