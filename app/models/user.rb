# require "../lib/controller"
class User < ActiveRecord::Base
  has_many :user_events #, dependent: :destroy
  has_many :events, through: :user_events

  def self.most_popular_location
    hash = Hash.new(0)
    self.all.each do |u|
      if hash[u.location] == nil
        hash[u.location] = 1
      else
        hash[u.location]+= 1
      end
    end
    hash.sort_by {|k, v| v}.last[0]
  end

  def total_cost
    total = 0
    self.events.each do |e|
      total += e.min_price
    end
    total
  end

  def upcoming_event
    if self.user_events != []
      show_event(1, self.events.sort_by {|e| e.date}.first)
    else
      puts " You have no events to view."
    end
  end

end # end of User class
