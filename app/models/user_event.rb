class UserEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :event


  def self.most_popular_event
    hash = Hash.new(0)
    self.all.each do |ue|
      if hash[ue.event] == nil
        hash[ue.event] = 1
      else
        hash[ue.event]+= 1
      end
    end
    show_event(1, hash.sort_by {|k, v| v}.last[0])
  end

  def self.most_popular_venue
    hash = Hash.new(0)
    self.all.each do |ue|
      if hash[ue.event.venue] == nil
        hash[ue.event.venue] = 1
      else
        hash[ue.event.venue]+= 1
      end
    end
    hash.sort_by {|k, v| v}.last[0]
  end

end # end of UserEvent class
