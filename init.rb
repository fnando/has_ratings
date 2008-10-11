require "has_ratings"
ActiveRecord::Base.send(:include, SimplesIdeias::Ratings::ActiveRecord)
ActionView::Base.send(:include, SimplesIdeias::Ratings::ActionView)

require File.dirname(__FILE__) + "/lib/rating"