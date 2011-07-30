#importvenues.rb

require 'yaml'

# Loads Knighfinder Data from a dumped YAML File

puts "This will oly run inside irb in Knightfinder ie. $irb -r ./knightfinder.rb\n"
puts "Run like \n\n\t$load_data(\"yamlfiletoimport.yml\")\n"

def load_data(source)
  file = File.read(source)
  @data = YAML.load(file)
  
  @data.each do |venue|
    item = Venue.new(venue)
    item.save!
    puts "Venue \"#{venue[:name]}\" added..."
  end
  
  puts "#{@data.count} venues written to Database"
end