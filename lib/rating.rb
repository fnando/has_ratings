class Rating < ActiveRecord::Base
  # associations
  belongs_to :rateable, :polymorphic => true, :counter_cache => true
  belongs_to :user
  
  # callbacks
  before_create   :keep_rateable_info
  before_destroy  :keep_rateable_info

  after_create    :update_rating_cache
  after_destroy   :update_rating_cache
  
  # validations
  validates_inclusion_of :rating, :in => (1..5)
  
  validates_presence_of :user
  
  validates_associated :user
    
  validates_uniqueness_of :user_id,
    :scope => [:rateable_type, :rateable_id]
  
  private
    def keep_rateable_info
      @rateable_info = {:rateable_id => rateable_id, :rateable_type => rateable_type}
    end
    
    def update_rating_cache
      klass = @rateable_info[:rateable_type].constantize
      object = klass.find(@rateable_info[:rateable_id]) rescue nil
      object.update_attribute(:rating, object.rating!) if object && object.respond_to?(:rating)
      nil
    end
end