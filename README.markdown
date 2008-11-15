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
        add_column :photos, :ratings_count, :integer,
		  :default => 0, :null => false
	
	    add_column :photos, :rating, :float,
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

Use this view helper to display the rating system:

	<%= rating_stars photo, current_user, rate_photo_path(photo) %>

Is based on [this article](http://www.thebroth.com/blog/119). You can get the
stars image at <http://f.simplesideias.com.br/stars.gif>. The CSS you need:

	ul.rating {
		width: 80px;
		height: 16px;
		margin: 0 10px 0 0;
		padding: 0;
		list-style: none;
		float:left;
		position: relative;
		background: url(../images/stars.gif) no-repeat 0 0;
	}

	ul.zero			{ background-position: 0 0; }
	ul.zero-half	{ background-position: 0 -16px; }
	ul.one			{ background-position: 0 -32px; }
	ul.one-half		{ background-position: 0 -48px; }
	ul.two			{ background-position: 0 -64px; }
	ul.two-half		{ background-position: 0 -80px; }
	ul.three		{ background-position: 0 -96px; }
	ul.three-half	{ background-position: 0 -112px; }
	ul.four			{ background-position: 0 -128px; }
	ul.four-half	{ background-position: 0 -144px; }
	ul.five			{ background-position: 0 -160px; }

	ul.rating li {
		cursor: pointer;
		float: left;
		text-indent: -999em;
	}

	ul.rated li {
		cursor: default;
	}

	ul.rating li a,
	ul.rating li span {
		position: absolute;
		left: 0;
		top: 0;
		width: 16px;
		height: 16px;
		text-decoration: none;
		z-index: 200;
	}

	ul.rating li.one a, ul.rating li.one span 		{ left:0; }
	ul.rating li.two a, ul.rating li.two span 		{ left:16px; }
	ul.rating li.three a, ul.rating li.three span 	{ left:32px; }
	ul.rating li.four a, ul.rating li.four span 	{ left:48px; }
	ul.rating li.five a, ul.rating li.five span 	{ left:64px; }

	ul.rating li a:hover {
		z-index: 2;
		width: 80px;
		height: 16px;
		overflow: hidden;
		left: 0;
		background: url(../images/stars.gif) no-repeat 0 0
	}

	ul.rating li.one a:hover	{ background-position:0 -176px; }
	ul.rating li.two a:hover	{ background-position:0 -192px; }
	ul.rating li.three a:hover	{ background-position:0 -208px; }
	ul.rating li.four a:hover	{ background-position:0 -224px; }
	ul.rating li.five a:hover	{ background-position:0 -240px; }

NOTE: You should have a User model. Otherwise, **this won't work**!

Copyright (c) 2008 Nando Vieira, released under the MIT license