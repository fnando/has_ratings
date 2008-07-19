class Rating < ActiveRecord::Base
  # constants
  MESSAGES = {
    :has_already_voted => "has already voted",
    :user_is_required => "is required",
    :rating_is_invalid => "should be between 1 and 5"
  }
  
  # associations
  belongs_to :rateable, :polymorphic => true
  belongs_to :user
  
  # validations
  validates_inclusion_of :rating, :in => (1..5), 
    :message => MESSAGES[:rating_is_invalid]
  
  validates_presence_of :user,
    :message => MESSAGES[:user_is_required]
  
  validates_associated :user,
    :message => MESSAGES[:user_is_required]
    
  validates_uniqueness_of :user_id,
    :scope => [:rateable_type, :rateable_id],
    :message => MESSAGES[:has_already_voted]
end