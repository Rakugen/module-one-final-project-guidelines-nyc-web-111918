class User < ActiveRecord::Base
  has_many :user_events
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
end # end of User class
