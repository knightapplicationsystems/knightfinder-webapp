#knightfinder.rb
require 'sinatra/base'
require 'bundler/setup'
require 'sinatra/activerecord'
require 'json'
require 'geokit'
require 'digest/md5'
require 'pony'


####################### MODELS #######################


class Venue < ActiveRecord::Base
  validates_presence_of :name
  has_many :deals
  has_many :visits
  has_many :logged_deal_views
  
  def self.active
    self.where(:active => true)
  end
  
  def active_deals
    self.deals.active.where("expires >= ?", (Time.now - 2.days))
  end
  
  def ll
    "#{self.latitude}, #{self.longitude}"
  end
  
  def self.find_by_id(id)
    self.where(id: id)[0]
  end
end

class Deal < ActiveRecord::Base
  belongs_to :venue
  
  def self.active
    self.where(:active => true).where("expires >= ?", (Time.now - 2.days))
  end
  
  def self.featured
    self.active.where(featured: true)
  end
  
  def self.find_by_id(id)
    self.where(id: id)[0]
  end
end

class Visit < ActiveRecord::Base
  belongs_to :venue
end

class LoggedSearch < ActiveRecord::Base
  
end

class LoggedDealSave < ActiveRecord::Base
  belongs_to :venue
end
  

####################### END MODELS #######################




####################### APPLICATION #######################

class KnightFinder < Sinatra::Base
  
  configure do
    Geokit::Geocoders::google = 'ABQIAAAA3u5SpqaF2DYRIsPQ7SUS7hTtwS2snXC5p7JJaiv_N14kY4e6ixTzc_jYNIKYYCenoUoNg0PNmLBWvg'
    set :method_override, true
  end
  
  ################## GENERAL WEB INTERFACE ###################

  get "/" do
    redirect "/login"
    puts "The DateTime, According to this ruby app is: #{Time.now}"
  end

  get "/login" do
    "Login Page"
    erb :login
  end

  post "/login" do
    #Log User in and redirect to view, based on attached venue_id
    #Post data must contain login credentials
  end


  ################## VENUES WEB INTERFACE ###################
  
  get "/new" do
    erb :create_venue
  end
  
  get "/:id" do
    @venue = Venue.find_by_id(params[:id])
    erb :show_venue
  end

  get "/:id/edit" do
    @venue = Venue.find_by_id(params[:id])
    erb :edit_venue
  end

  put "/:id" do
    puts "UPDATING VENUE #{params[:id]}"
    @venue = Venue.find_by_id(params[:id])
    
    # Remove method and submit attributes from the hash so update_attributes can process it.
    params.delete("_method")
    params.delete("Submit")
    
    @venue.update_attributes(params)
    redirect "#{params[:id]}"
  end
  
  post "/new" do
    puts "CREATING VENUE #{params[:id]}..."
    # Remove method and submit attributes from the hash so update_attributes can process it.
    # params.delete("_method")
    params.delete("Submit")
    
    @venue = Venue.new(params)
    if @venue.save
      puts "...DONE"
      redirect @venue.id
    else
      puts "VENUE NOT CREATED"
      status 500
      "Venue Not Created"
    end
    
  end

  delete "/:id" do
    status 403
    "You Cannot Delete Venues"
  end
  
  put "/:id/registration" do
    puts "REGISTERING VENUE #{params[:id]}"
    @venue = Venue.find_by_id(params[:id])
    
    # Remove method and submit attributes from the hash so update_attributes can process it.
    params.delete("_method")
    params.delete("Submit")
    
    @venue.login_email = params[:login_email]
    @venue.crypted_password = Digest::MD5.hexdigest(params[:password])
    
    # Send an Email to the Admin Address
    
    @return = Pony.mail(
      to: params[:login_email],
      from: "info@knightfinderapp.com",
      subject: "#{@venue.name} has been registered on KnightFinder",
      body: "Your Password is: #{params[:password]}",
      :via => :smtp,
      via_options: {
        :address        => 'smtp.sendgrid.net',
        :port           => '25',
        :authentication => :plain,
        :user_name      => ENV['SENDGRID_USERNAME'],
        :password       => ENV['SENDGRID_PASSWORD'],
        :domain         => ENV['SENDGRID_DOMAIN']
    })
    
    if @venue.save
      puts @return.inspect
      redirect "#{params[:id]}"
    end
    
  end

  ################## DEALS WEB INTERFACE ###################

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

  post "/:venue_id/deals" do
    puts "CREATING DEAL FOR #{params[:id]}..."
    # Remove method and submit attributes from the hash so update_attributes can process it.
    params.delete("Submit")
    
    @deal = Venue.find_by_id(params[:venue_id]).deals.new(params)
    if @deal.save
      redirect "/#{params[:venue_id]}"
    end
  end

  put "/:venue_id/deals/:id" do
    @deal = Deal.find_by_id(params[:id])
    params.delete("_method")
    params.delete("Submit")
    
    @deal.update_attributes!(params)
    redirect "/#{params[:venue_id]}"
  end
  
  delete "/:venue_id/deals/:id" do
    @deal = Deal.find_by_id(params[:id])
    if @deal.delete
      redirect "/#{params[:venue_id]}"
    end
  end

  
  ########## TESTING & DEVELOPMENT CODE ###########
  
  get '/api/timeout_test' do
    x = 32
    puts "Testing Timeout... Waiting for #{x} seconds"
    sleep(x)
    status 200
    puts "Waited for #{x} seconds... OK"
    "Waited for #{x} seconds"
  end
  
  
  ################## WEB SERVICE API ###################
  
  
  # Expects "/api/venues?q=City" or "/api/venues?loc=45.6456677,0.567765&limit=50". Will fail with 400 on anything else.
  # ENSURE: Latitude then Londitude!
  
  get "/api/venues" do
    
    # Write to the LoggedSearches that a search has been done.
    
    @logged_search = LoggedSearch.new(  :request_uri  => request.env["REQUEST_URI"],
                                        :remote_ip    => request.env["REMOTE_ADDR"],
                                        :user_agent   => request.env["HTTP_USER_AGENT"],
                                        :location     => params[:loc],
                                        :limit        => params[:limit],
                                        :query        => params[:q])
    @logged_search.save!
    puts "Search call to #{request.env["REQUEST_URI"]} logged"
    
    
    # If the loc and limit paramaters have been sent.
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
      Venue.active.each do |venue|
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
      venues_by_city = Venue.active.where("city lIKE ?", "%#{params[:q]}%").group_by {|e| e.city }
      venues_by_name = Venue.active.where("name LIKE ?", "%#{params[:q]}%")
      
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
    
    @deals = Venue.find_by_id(params[:id]).active_deals
    
     if @deals.length < 1
        status 404
        "No Deals Found"
      else
        status 200
        content_type :json
        @deals.to_json
      end
  end

  # Logs a record to the LoggedDealSaves
  # GET Because this shouldn't be protected in any way - it's only a logger.
  get "/api/venue/:venue_id/deals/:deal_id/log" do
    
    @logged_deal_save = LoggedDealSave.new( :request_uri  => request.env["REQUEST_URI"],
                                            :remote_ip    => request.env["REMOTE_ADDR"],
                                            :user_agent   => request.env["HTTP_USER_AGENT"],
                                            :venue_id     => params[:venue_id],
                                            :deal_id      => params[:deal_id],
                                            :deal_summary => Deal.find_by_id(params[:deal_id]).summary)
    if @logged_deal_save.save!
      puts "Deal :deal_id for #{Venue.find_by_id(params[:venue_id]).name} was saved by a user"
      status 201
      "Save Logged"
    else
      status 500
      "Internal Server Error - Failed to log deal save"
    end
    
  end


  # Returns featured deals as JSON.
  get "/api/featureddeals" do
    @deals = Deal.featured

    if @deals.length < 1
      status 404
      "There are no Featured Deals"
    else
      status 200
      content_type :json
      @deals.to_json
    end
  end
    
  
  # Expects "longitude", "latitude" and "city" as POSTDATA.
  # GET Because this shouldn't be protected in any way - it's only a logger.
  get "/api/venue/:id/log" do
    
    @venue = Venue.find_by_id(params[:id])
    @visit = @venue.visits.new(   :request_uri  => request.env["REQUEST_URI"],
                                  :remote_ip    => request.env["REMOTE_ADDR"],
                                  :user_agent   => request.env["HTTP_USER_AGENT"],
                                  :longitude   => params[:longitude],
                                  :latitude    => params[:latitude],
                                  :city         => params[:city])
                        
    if @visit.save!
      puts "Visit to #{@venue.name} was logged"
      status 201
      "Visit Logged"
    else
      status 500
      "Internal Server Error - Failed to log visit"
    end
    
  end

  
  # Returns a single venue as JSON.
  # NOT USED YET
  get "/api/venue/:id" do
    status 200
    content_type :json
    Venue.find_by_id(params[:id]).to_json
  end

end