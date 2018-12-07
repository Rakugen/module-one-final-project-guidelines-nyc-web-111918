def welcome
  a = Artii::Base.new :font => 'doh'
  puts ""
  puts "Welcome to"
  puts a.asciify('Event.Ful')
  puts "A Mod 1 Project"
  puts "Programmed by Simon Lee and Connor Finnegan"

  puts "Here you can find and save upcoming events to your own profile."
  puts "Can't think of what you'd like to see? Use our search feature"
  puts "to see whats hot in the area!"
  puts ""

end

def login
  puts "Enter your name to access your account:"
  user_name = gets.chomp
  if User.find_by(name: user_name) == nil
    puts "User not found."
    create_user
  else
    @user = User.find_by(name: user_name)
    puts "You are now logged in as #{user_name}."
  end
end

def create_user
  puts "Please enter your first name to create a new account. [Example: Simon]"
  name = gets.chomp
  puts "Please enter your location in city-state format. [Example: Boston, MA]"
  location = gets.chomp
  puts "Please enter your age as a number. [Example: 28]"
  age = gets.chomp
  @user = User.create(name: name, location: location, age: age)
end

def delete_user
  puts "Please enter the name of the user you would like to delete."
  puts ""
  User.all.each do |u|
    puts u.name
  end
  puts ""
  name = gets.chomp
  if User.all.map {|u| u.name}.include?(name)
    User.destroy(User.find_by(name: name).id)
  else
    puts "That user does not exist."
    menu
  end
end

def switch_user
  puts "Please enter the name of the user you'd like to switch to:"
  puts ""
  User.all.each do |u|
    puts u.name
  end
  puts ""
  user_name = gets.chomp

  if User.find_by(name: user_name) != nil
    puts "You are now logged in as #{user_name}."
    @user = User.find_by(name: user_name)
  else
    puts "Failed to login. Account not found."
    puts ""
  end
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
    # old_user = @user
    @user = User.find(@user.id)
    binding.pry
    puts str
  else
    puts ""
    puts "You have no events to delete."
    puts ""
  end
  # @user.update_all
  # binding.pry
end

def search
  # puts "You can search by name, location, and venue."
  input1 = ""
  terms = ["name","location","venue"]
  while !terms.include?(input1)
    puts "Enter your search type: (name, location, venue)"
    input1 = gets.chomp.downcase
  end
  puts "What would you like to search for?"
  input2 = gets.chomp

  case input1
    when "name"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&" + "keyword=#{input2}" + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    # when "attraction"
    #   @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "attraction=#{input2}" + "&page=1&size=20&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "location"
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?countryCode=US&" + "city=#{input2}" + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    when "venue"
      ven_hash = JSON.parse(RestClient.get("https://app.ticketmaster.com/discovery/v2/venues.json?countryCode=US&" + "keyword=#{input2}" + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"))
      ven_id = ven_hash["_embedded"]["venues"][0]["id"]
      @url = "https://app.ticketmaster.com/discovery/v2/events.json?" + "venueId=#{ven_id}" + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
    else
      puts "Invalid Search"
      puts ""
  end

  hash = call_api
  if hash == nil
    return
  end

  num = 0
  if hash["page"]["totalElements"] != 0
    hash["_embedded"]["events"].each do |event|
      num += 1
      display_event(num, event)
    end

    input4 = ""
    while input4 != "no"
      save(hash)
      if hash == nil
        # binding.pry
        # puts "Error on second next page call"
        input4 = "no"
      elsif hash["_links"]["next"] != nil
        puts "Would you like to view more results? Yes or no?"
        input4 = gets.chomp.downcase
          if input4 == "yes"
            next_page
            hash = call_api
            # binding.pry
            num = 0
            if hash["page"]["totalElements"] != 0
              hash["_embedded"]["events"].each do |event|
                num += 1
                display_event(num, event)
              end
            end
          else
            input4 = "no"
          end
      else
        input4 = "no"
      end
    end
  else
    puts ""
    puts "No search results found."
    puts ""
  end
end

def save(hash)
  puts "Would you like to save an event? Yes or no?"
  input3 = gets.chomp.downcase

  if input3 == "yes"
    input4 = 0
    while !((1..hash["_embedded"]["events"].length).include?(input4))
      puts "Which number would you like to save? (1-20)"
      input4 = gets.chomp.to_i
    end
    # hash = call_api
    event = hash["_embedded"]["events"][input4.to_i - 1]
    name = event["name"]
    if date = event["dates"]["start"]["dateTime"] == nil
      puts "Unable to save event."
      return
    else
      date = event["dates"]["start"]["dateTime"]
    end
    location = event["_embedded"]["venues"][0]["city"]["name"] +", "+ event["_embedded"]["venues"][0]["state"]["stateCode"]
    venue = event["_embedded"]["venues"][0]["name"]
    if event["_embedded"]["attractions"] == nil
      puts "Unable to save event."
      return
    else
      attractions = event["_embedded"]["attractions"].map {|a| a["name"]}
    end
    if event["priceRanges"] == nil
      puts "Unable to save event."
      return
    else
      min_price = event["priceRanges"][0]["min"]
    end
    classification = event["classifications"][0].values[1...-1].map {|c| c["name"]}
    e = Event.find_or_create_by(name: name, date: Time.parse(date), location: location, venue: venue, attractions: attractions.join(", "), min_price: min_price, classification: classification.join(", "))
    UserEvent.find_or_create_by(user_id: @user.id, event_id: e.id)
    puts "#{e.name} has been saved to your events!"

  elsif input3 != "no"
    save(hash)
  else
    return
  end

end

def display_event(num, event)
  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
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
  puts "Classifications: #{event["classifications"][0].values[1...-1].map {|c| c["name"]}}"
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""
end

def next_page
  hash = call_api
  if hash == nil
    puts "Error from next page."
  end
  hash["_links"]["next"]["href"]
  @url = "https://app.ticketmaster.com/" + hash["_links"]["next"]["href"] + "&apikey=heXwN4lrodGKyLyOeXrVsV9MpB8W7e5w"
end

def run
  welcome
  login
  response = menu
  while response != "exit"
    response = menu
  end
# binding.pry
end

def menu
  puts ""
  puts "======================================================"
  puts "What would you like to do?"
  puts "1. Create User"
  puts "2. Delete User"
  puts "3. Search for an event"
  puts "4. View your saved events"
  puts "5. Delete a saved event"
  puts "6. View all users"
  puts "7. Switch users"
  puts "8. My event stats "
  puts ""
  puts "Type 'Exit' to quit the program"
  puts "======================================================"
  input = gets.chomp
  case input.downcase
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
  when "7"
    switch_user
    puts ""
  when "8"
    menu2
  when "exit"
    "exit"
  else
    menu
  end
end

def menu2
  puts ""
  puts "======================================================"
  puts "What would you like to do?"
  puts "1. See most popular event people have saved"
  puts "2. View total cost of my events"
  puts "3. View my upcoming event"
  puts "4. Most popular location by users"
  puts "5. View most popular venue"
  # puts "6. "
  # puts "7. "
  # puts "8. "
  puts ""
  puts "Type 'Exit' to return to Main Menu"
  puts "======================================================"
  input = gets.chomp
  case input
  when "1"
    puts ""
    puts UserEvent.most_popular_event
    puts ""
  when "2"
    puts ""
    puts "$#{@user.total_cost}"
    puts ""
  when "3"
    @user.upcoming_event
  when "4"
    puts ""
    puts User.most_popular_location
    puts ""
  when "5"
    puts ""
    puts UserEvent.most_popular_venue
    puts ""
  # when "5"
  # when "6"
  # when "7"
  # when "8"
  else
    "exit"
  end
  menu
end

def call_api
  res = RestClient.get(@url){|response, request, result, &block|
    case response.code
    when 200
      return JSON.parse(response)
    else
      puts "The servers are overloaded!!!"
      menu
    end
  }
  res
end

def show_event(num, e)
  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts "#{num}."
  puts "Name: #{e.name}"
  puts "Date: #{e.date.to_date}"
  puts "Location: #{e.location}"
  puts "Venue: #{e.venue}"
  puts "Attractions: #{e.attractions}"
  puts "Price: $#{e.min_price}"
  puts "Classifications: #{e.classification}"
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""
end
