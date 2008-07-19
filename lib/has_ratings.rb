module SimplesIdeias
  module Acts
    module Ratings
      def self.included(base)
        base.extend SimplesIdeias::Acts::Ratings::ClassMethods
        
        class << base
          attr_accessor :has_rating_options
        end
      end
      
      module ClassMethods
        def has_ratings
          self.has_rating_options = {
            :type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          }
          
          # associations
          has_many :ratings, :as => :rateable, :dependent => :destroy
          
          include SimplesIdeias::Acts::Ratings::InstanceMethods
        end
      end
      
      module InstanceMethods
        def rated?(owner)
          !find_rating_by_user(owner).nil?
        end
        
        def find_rating_by_user(owner)
          owner = owner.id if owner.is_a?(User)
          self.ratings.find(:first, :conditions => {:user_id => owner})
        end
        
        def rating_average
          Rating.average(:rating, {
            :conditions => {
              :rateable_type => self.class.has_rating_options[:type],
              :rateable_id => self.id
            }
          })
        end
        
        def rate(options)
          self.ratings.create(options)
        end
        
        def find_users_that_rated(options={})
          options = {
            :limit => 20,
            :conditions => ["ratings.rateable_type = ? and ratings.rateable_id = ?", self.class.has_rating_options[:type], self.id],
            :include => :ratings
          }.merge(options)

          User.find(:all, options)
        end
      end
    end
  end
end