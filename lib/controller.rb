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

  case input1
    when "name"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "keyword=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "attraction"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "attraction=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "location"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "city=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    # when "price"
    #   url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "keyword=#{input1}" + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "venue"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "venueid=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    else
      puts "Invalid Search"
  end
  hash = JSON.parse(RestClient.get(@url))
  hash["_embedded"]["events"].each do |event|
    display_event(event)
  end



  puts "Would you like to save an event? yes or no?"
  input3 = gets.chomp
  if input3 == "yes"
    puts "Which number would you like to save? (1-20)"
    input4 = gets.chomp
    save(input4)
  end

  #What do we want to allow our user to do next? (after saving/not saving)

  # us_events_hash =  JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/events.json?city=Philadelphia&page=1&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"))
  # Event.where("#{input1} = ?", "#{input2}").each {|e| display_event(e)}
  # nil
end

def save(num)
  hash = JSON.parse(RestClient.get(@url))
  event = hash["_embedded"]["events"][num.to_i - 1]
  #         name, date, location, venue, attractions, min_price, classsification
  name = event["name"]
  date = event["dates"]["start"]["dateTime"]
  location = event["_embedded"]["venues"][0]["city"]["name"] +", "+ event["_embedded"]["venues"][0]["state"]["stateCode"]
  venue = event["_embedded"]["venues"][0]["name"]
  attractions = event["_embedded"]["attractions"].map {|a| a["name"]}
  min_price = event["priceRanges"][0]["min"]
  classification = event["classifications"][0].values[1...-1].map {|c| c["name"]}
  e = Event.create(name: name, date: date, location: location, venue: venue, attractions: attractions.join(", "), min_price: min_price, classification: classification.join(", "))
  UserEvent.create(user_id: @user.id, event_id: e.id)
end

def seed
  url = "https://app.ticketmaster.com//discovery/v2/events.json?countryCode=US&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
  @us_events_hash = JSON.parse(RestClient.get(url))
  @us_events_hash["_embedded"]["events"].each do |event|
    # event["name"]
    display_event(event)
  end
  next_page
end

def display_event(event)
  # event = JSON.parse(RestClient.get(@url))
  # event = event["_embedded"]["events"]
  puts ""
  puts "Name: #{event["name"]}"
  puts "Location: #{event["_embedded"]["venues"][0]["city"]["name"]}, #{event["_embedded"]["venues"][0]["state"]["stateCode"]}"
  puts "Venue: #{event["_embedded"]["venues"][0]["name"]}"
  puts "Date: #{event["dates"]["start"]["dateTime"]}"
  if event["_embedded"]["attractions"] != nil
    puts "Attractions: #{event["_embedded"]["attractions"].map {|a| a["name"]}}"
  end
  if event["priceRanges"] != nil
    puts "Tickets starting at: $#{event["priceRanges"][0]["min"]}"
  end
  puts "Categories: #{event["classifications"][0].values[1...-1].map {|c| c["name"]}}"
  # binding.pry
  puts "//////////////////////////////////////////////"
  puts ""
end

def next_page
  hash = JSON.parse(RestClient.get(@url))
  hash["_links"]["next"]["href"]
  url = "https://app.ticketmaster.com/" + hash["_links"]["next"]["href"] + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
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
