def welcome
  puts "Welcome to the Event Finder."
end

def create_user
  puts "Please enter your first name [Example: Simon]"
  name = gets.chomp
  puts "Please enter your location in city-state format [Example: Boston, MA]"
  location = gets.chomp
  puts "Please enter your age as a number [Example: 28]"
  age = gets.chomp
  @user = User.create(name: name, location: location, age: age)
end

def delete_user
  puts "Please enter the name of the user you would like to delete"
  name = gets.chomp
  User.destroy(User.find_by(name: name).id)
end

def save_event(event_id)
  User.find(@user.id).events << Event.find(event_id)
  # UserEvent.create(user_id: user_id, event_id: event_id)
  puts "#{Event.find(event_id).name} has been added to your saved events!"
end

def delete_event(user_event_id)
  str = "#{UserEvent.find(user_event_id).event.name} has been removed from events!"
  UserEvent.destroy(UserEvent.find(user_event_id))
  puts str
end

def login
  puts "Please enter your name that you would like to login with:"
  user_name = gets.chomp
  puts "You are now logged in as #{User.find_by(name: user_name).name}."
  User.find_by(name: user_name)
end

def search
  puts "You can search by name, attraction, location, price, classification and venue."
  puts "Enter your search type:"
  input1 = gets.chomp
  puts "Enter your search term:"
  input2 = gets.chomp
  us_events_hash =  JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?city=Philadelphia&page=1&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"))
  Event.where("#{input1} = ?", "#{input2}").each {|e| display_event(e)}
  nil

end

def seed
  us_events_hash =  JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?city=Philadelphia&page=1&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"))
  us_events_hash["_embedded"]["events"].map do |event|
    event["name"]
    binding.pry
  end
end

def display_event(event)
  # puts ""
  # puts "Name: #{event.name}"
  # puts "Location: #{event.location}"
  # puts "Venue: #{event.venue}"
  # puts "Date: #{event.date}"
  # puts "Attractions: #{event.attractions}"
  # puts "Tickets starting at: $#{event.min_price}"
  # puts "Category: #{event.classification}"
  # puts "//////////////////////////////////////////////"
  # puts ""
  puts ""
  puts "Name: #{event["name"]}"
  puts "Location: #{event["_embedded"]["venues"][0]["city"]["name"]}, #{event["_embedded"]["venues"][0]["state"]["stateCode"]}"
  puts "Venue: #{event["_embedded"]["venues"][0]["name"]}"
  puts "Date: #{event["dates"]["start"]["dateTime"]}"
  puts "Attractions: #{event["_embedded"]["attractions"].map {|a| a["name"]}}"
  binding.pry
  puts "Tickets starting at: $#{event["priceRanges"][0]["min"]}"
  # puts "Category: #{event["classifications"].map {|c| c["segment"]["name"]}}"
  puts "//////////////////////////////////////////////"
  puts ""

end

def run
  welcome
  @user = login

  # create_user method here
  # delete_user method here
  # logout method here
  # switch user method here
  # search for events method here

binding.pry
end
