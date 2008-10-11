module SimplesIdeias
  module Ratings
    module ActionView
      def rating_stars(object, user, url)
        rating = object.rating
        css_names = %w(zero one two three four five)
        css_rating = css_names[rating.to_i]
        diff = ('%.1f' % (rating.to_f - rating.to_i)).to_f

        if (0.1..0.5).include?(diff)
          css_rating << '-half'
        elsif (0.6..0.9).include?(diff)
          css_rating = css_names[rating.to_i + 1]
        end
        
        if object.rated?(user)
          %(
            <ul class="rating #{css_rating} rated">
              <li class="one"><span>1</span></li>
              <li class="two"><span>2</span></li>
              <li class="three"><span>3</span></li>
              <li class="four"><span>4</span></li>
              <li class="five"><span>5</span></li>
            </ul>
          )
        else
          %(
            <ul class="rating #{css_rating}">
              <li class="one"><a href="#{url}?r=1" title="1 Star" rel="no-follow">1</a></li>
              <li class="two"><a href="#{url}?r=2" title="2 Stars" rel="no-follow">2</a></li>
              <li class="three"><a href="#{url}?r=3" title="3 Stars" rel="no-follow">3</a></li>
              <li class="four"><a href="#{url}?r=4" title="4 Stars" rel="no-follow">4</a></li>
              <li class="five"><a href="#{url}?r=5" title="5 Stars" rel="no-follow">5</a></li>
            </ul>
          )
        end
      end
    end
    
    module ActiveRecord
      def self.included(base)
        base.extend SimplesIdeias::Ratings::ActiveRecord::ClassMethods
      
        class << base
          attr_accessor :has_rating_options
        end
      end
    
      module ClassMethods
        def has_ratings
          include SimplesIdeias::Ratings::ActiveRecord::InstanceMethods
        
          self.has_rating_options = {
            :type => ::ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
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