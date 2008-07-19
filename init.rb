require "has_ratings"
ActiveRecord::Base.send(:include, SimplesIdeias::Acts::Ratings)

require File.dirname(__FILE__) + "/lib/rating"