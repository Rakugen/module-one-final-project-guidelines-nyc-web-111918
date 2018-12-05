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

def delete_event
  num = 0
  num_arr = []
  input1 = ""
  if @user.user_events != []
    @user.user_events.each do |ue|
      num += 1
      num_arr << num
      show_event(num, ue.event)
    end

    while !num_arr.include?(input1.to_i)
      puts "Which event would you like to delete?"
      input1 = gets.chomp
    end
# binding.pry
    str = "#{@user.user_events[input1.to_i - 1].event.name} has been removed from events!"
    @user.user_events[input1.to_i - 1].destroy
    puts str
  else
    puts ""
    puts "You have no events to delete."
    puts ""
  end
end

def login
  puts "Enter your name to access your account, or create a new one with:"
  user_name = gets.chomp
  puts "You are now logged in as #{user_name}."
  User.find_or_create_by(name: user_name)
end

def search
  puts "You can search by name, attraction, location, classification and venue."
  input1 = ""
  terms = ["name","attraction","location","venue"]
  while !terms.include?(input1)
    puts "Enter your search type:"
    input1 = gets.chomp
  end
  puts "Enter your search term:"
  input2 = gets.chomp

  case input1
    when "name"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "keyword=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "attraction"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "attraction=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "location"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "city=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "venue"
      ven_hash = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/venues.json?countryCode=US&keyword=" + input2 + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"))
      ven_id = ven_hash["_embedded"]["venues"][0]["id"]
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "venueId=#{ven_id}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    else
      puts "Invalid Search"
  end
  hash = JSON.parse(RestClient.get(@url))
  num = 0
  if hash["page"]["totalElements"] != 0
    hash["_embedded"]["events"].each do |event|
      num += 1
      display_event(num, event)
    end

    input4 = ""
    while input4 != "no"
      save
      puts "Would you like to view more results?"
      input4 = gets.chomp
        if input4 == "yes"
          next_page
          hash = JSON.parse(RestClient.get(@url))
          num = 0
          if hash["page"]["totalElements"] != 0
            hash["_embedded"]["events"].each do |event|
              num += 1
              display_event(num, event)
            end
          end
        end
      end
  else
    puts ""
    puts "No search results found."
    puts ""
  end
end

def save
  puts "Would you like to save an event? yes or no?"
  input3 = gets.chomp
  if input3 == "yes"
    puts "Which number would you like to save? (1-20)"
    input4 = gets.chomp
    event = hash["_embedded"]["events"][input4.to_i - 1]
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

  # hash = JSON.parse(RestClient.get(@url))
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

def display_event(num, event)
  puts ""
  puts "#{num}."
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
  puts "//////////////////////////////////////////////"
  puts ""
end

def next_page
  hash = JSON.parse(RestClient.get(@url))
  hash["_links"]["next"]["href"]
  @url = "https://app.ticketmaster.com/" + hash["_links"]["next"]["href"] + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
end

def run
  welcome
  @user = login
  response = menu
  while response != "7"
    response = menu
  end
# binding.pry
end

def menu
  puts "What would you like to do?"
  puts "1. Create User"
  puts "2. Delete User"
  puts "3. Search for an event"
  puts "4. View your saved events"
  puts "5. Delete a saved event"
  puts "6. View all users"
  puts "7. Exit"

  input = gets.chomp
  case input
  when "1"
    create_user
  when "2"
    delete_user
  when "3"
    search
  when "4"
    num = 0
    if @user.user_events != []
      @user.user_events.each do |ue|
        num += 1
        show_event(num, ue.event)
      end
    else
      puts ""
      puts "You have no events. =[ "
      puts ""
    end
  when "5"
    delete_event
  when "6"
    puts ""
    User.all.each do |u|
      puts u.name
    end
    puts ""
  else
    "7"
  end
end

def show_event(num, e)
  puts ""
  puts "#{num}."
  puts e.name
  puts e.date
  puts e.location
  puts e.venue
  puts e.attractions
  puts e.min_price
  puts e.classification
  puts "//////////////////////////////////"
  puts ""
end
