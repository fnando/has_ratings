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
          include SimplesIdeias::Acts::Ratings::InstanceMethods
          
          self.has_rating_options = {
            :type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          }
          
          # associations
          has_many :ratings, :as => :rateable, :dependent => :destroy
          
          # named scopes
          named_scope :best_rated, :order => 'rating desc'
          named_scope :most_rated, :order => 'ratings_count desc'
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
        
        def rating!
          Rating.average(:rating, {
            :conditions => {
              :rateable_type => self.class.has_rating_options[:type],
              :rateable_id => self.id
            }
          })
        end
        
        def rate(options)
          options[:user_id] = options.delete(:user).id if options[:user]
          self.ratings.create(options)
        end
        
        def find_users_that_rated(options={})
          options = {
            :limit => 10,
            :conditions => ["ratings.rateable_type = ? and ratings.rateable_id = ?", self.class.has_rating_options[:type], self.id],
            :include => :ratings
          }.merge(options)

          if Object.const_defined?('Paginate')
            User.paginate(options)
          else
            User.all(options)
          end
        end
      end
    end
  end
end