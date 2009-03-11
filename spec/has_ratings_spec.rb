require "spec_helper"

# unset models used for test purposes
Object.unset_class('User', 'Donut', 'Beer')

class User < ActiveRecord::Base
  has_many :ratings, :dependent => :destroy
end

class Beer < ActiveRecord::Base
  has_ratings
end

class Donut < ActiveRecord::Base
  has_ratings
end

describe "has_ratings" do
  fixtures :users, :beers, :donuts
  
  before(:each) do
    @user = users(:homer)
    @another_user = users(:barney)
    @beer = beers(:duff)
    @donut = donuts(:cream)
  end
  
  it "should have ratings association" do
    lambda { @beer.ratings }.should_not raise_error
    lambda { @donut.ratings }.should_not raise_error
  end
  
  it "should create a rating with <user> object" do
    lambda do
      @beer.rate(:user => @user, :rating => 3)
    end.should change(Rating, :count).by(1)
  end
  
  it "should create a rating with :user_id attribute" do
    lambda do
      @beer.rate(:user_id => @user.id, :rating => 3)
    end.should change(Rating, :count).by(1)
  end
  
  it "should require user" do
    lambda do
      rating = @beer.rate(:user => nil, :rating => 3)
      rating.errors.on(:user).should_not be_nil
      
      rating = @beer.rate(:user_id => nil, :rating => 3)
      rating.errors.on(:user).should_not be_nil
    end.should_not change(Rating, :count)
  end
  
  it "should require valid rating" do
    lambda do
      rating = @beer.rate(:user => @user, :rating => 0)
      rating.errors.on(:rating).should_not be_nil
      
      rating = @beer.rate(:user_id => @user, :rating => 6)
      rating.errors.on(:rating).should_not be_nil
    end.should_not change(Rating, :count)
  end
  
  it "should deny duplicated rating with object as scope" do
    lambda do
      rating = @beer.rate(:user => @user, :rating => 3)
      rating.should be_valid
      
      another_rating = @beer.rate(:user => @user, :rating => 3)
      another_rating.should_not be_valid
    end.should change(Rating, :count).by(1)
  end
  
  it "should rate different objects" do
    lambda do
      rating = @beer.rate(:user => @user, :rating => 3)
      rating.should be_valid
      
      another_rating = @donut.rate(:user => @user, :rating => 3)
      another_rating.should be_valid
    end.should change(Rating, :count).by(2)
  end
  
  it "should rate different objects with different users" do
    lambda do
      rating = @beer.rate(:user => @user, :rating => 3)
      rating.should be_valid
      
      another_rating = @beer.rate(:user => @another_user, :rating => 3)
      another_rating.should be_valid
    end.should change(Rating, :count).by(2)
  end
  
  it "should get unique users that rated duff" do
    @beer.rate(:user => @user, :rating => 3)
    @beer.rate(:user => @user, :rating => 3)
    @beer.rate(:user => @another_user, :rating => 3)
    
    @beer.find_users_that_rated.should == [@user, @another_user]
  end
  
  it "should get users that bookmarked only on duff" do
    @beer.rate(:user => @user, :rating => 3)
    @donut.rate(:user => @another_user, :rating => 3)
    
    @beer.find_users_that_rated.should == [@user]
  end
  
  it "should get rating from a given user" do
    rating = @beer.rate(:user => @user, :rating => 3)
    one_more_rating = @donut.rate(:user => @user, :rating => 3)
    
    @beer.find_rating_by_user(@user).should == rating
  end
  
  it "should mark beer as rated" do
    rating = @beer.rate(:user => @user, :rating => 3)
    @beer.should be_rated(@user)
  end
  
  it "should get not-cached rating average" do
    @beer.rate(:user => @user, :rating => 4)
    @beer.rate(:user => @another_user, :rating => 5)
    
    @beer.rating!.should == 4.5
  end
  
  it "should get cached rating average" do
    @beer.rate(:user => @user, :rating => 4)
    @beer.rate(:user => @another_user, :rating => 5)
    @beer.reload
    Rating.should_not_receive(:average)
    @beer.rating.should == 4.5
  end

  it "should never have a nil rating average" do
    @beer.rating!.should_not be_nil
  end
  
  it "should set user from object" do
    rating = @beer.rate(:user => @user, :rating => 4)
    rating.user.should == @user
  end
  
  it "should set user from id" do
    rating = @beer.rate(:user_id => @user.id, :rating => 4)
    rating.user.should == @user
  end
  
  it "should update cached rating average if rating object is removed" do
    @beer.rate(:user => @user, :rating => 4)
    rating = @beer.rate(:user => @another_user, :rating => 5)
    rating.destroy
    @beer.reload
    @beer.rating.should == 4.0
  end
  
  it "should update counter" do
    @beer.rate(:user => @user, :rating => 4)
    @beer.rate(:user => @another_user, :rating => 5)
    @beer.reload
    @beer.ratings_count.should == 2
  end
  
  it "should set named scopes" do
    Beer.most_rated.proxy_options.should == {:order => 'ratings_count desc'}
    Beer.best_rated.proxy_options.should == {:order => 'rating desc'}
  end
  
  it "should return paginated users" do
    pending unless Object.const_defined?("Paginate")
    
    User.delete_all
    Array(30) do |i| 
      user = User.create!(:name => "User #{i}")
      @beer.rate(:user => user, :rating => 3)
    end

    @beer.find_users_that_rated(:page => 1).should == User.all(:limit => 10)
    @beer.find_users_that_rated(:page => 2).should == User.all(:limit => 10, :offset => 10)
  end
end
