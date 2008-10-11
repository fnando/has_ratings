has_ratings
===========

Instalation
-----------

1) Install the plugin with `script/plugin install git://github.com/fnando/has_ratings.git`

2) Generate a migration with `script/generate migration create_ratings` and add the following code:

	class CreateRatings < ActiveRecord::Migration
	  def self.up
	    create_table :ratings do |t|
	      t.integer :rating, :default => 0, :null => false
	      t.references :rateable, :polymorphic => true
	      t.references :user
	      t.timestamps
	    end
    
	    add_index :ratings, :rateable_type
	    add_index :ratings, :rateable_id
	    add_index :ratings, :user_id
	  end

	  def self.down
	    drop_table :ratings
	  end
	end

3) Add two columns on each model you're going to use `has_ratings`: `ratings_count` and `rating`

	class AddRatingToPhoto < ActiveRecord::Migration
	  def self.up
        add_column :photos, :integer,
		  :default => 0, :null => false
	
	    add_column :photos, :float,
		  :precision => 3, 
		  :scale => 2,
		  :default => 0,
		  :null => false

	    add_index :photos, :rating
	    add_index :photos, :ratings_count
	  end

	  def self.down
	    remove_index :photos, :rating
	    remove_column :photos, :rating
	
		remove_index :photos, :ratings_count
	    remove_column :photos, :ratings_count
	  end
	end

4) Run the migrations with `rake db:migrate`

Usage
-----

1) Add the method call `has_rating` to your model.

	class Photo < ActiveRecord::Base
	  has_ratings
	end

2) Add this association on your User model:

	class User < ActiveRecord::Base
	  has_many :ratings
	end

	photo = Photo.find(:first)
	user = User.find(:first)

	photo.rate(:user => user, :rating => 1) # => <rating>
	photo.rated?(user) # => true
	photo.ratings # => [<rating>]
	photo.rating! # => 0.0 (will skip rating cache)
	photo.rating # => will use non-cached rating attribute
	photo.ratings_count # => ratings count
	photo.find_users_that_rated # => []
	photo.find_rating_by_user(user) # => <rating>
	
	# retrieve best rated objects (order by rating desc)
	Photo.best_rated # => [<photo>]
	
	# retrieve most rated objects (order by ratings_count desc)
	Photo.most_rated # => [<photo>]

If you have [has_paginate](http://github.com/fnando/has_paginate) installed, 
you can paginate the users that rated a given item:

	photo.find_users_that_rated(:page => 2)

NOTE: You should have a User model. Otherwise, **this won't work**!

Copyright (c) 2008 Nando Vieira, released under the MIT license