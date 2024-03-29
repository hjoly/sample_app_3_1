require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :username => "user.example",
      :password => "foobar",
      :password_confirmation => "foobar",
      :notified_on_new_follower => true
    }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name=> ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email=> ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do 
    long_name = "a" * 51 
    long_name_user = User.new(@attr.merge(:name => long_name)) 
    long_name_user.should_not be_valid 
  end

  it "should accept valid email addresses" do 
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp] 
    addresses.each do |address| 
      valid_email_user = User.new(@attr.merge(:email => address)) 
      valid_email_user.should be_valid 
    end 
  end  

  it "should reject invalid email addresses" do 
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.] 
    addresses.each do |address| 
      invalid_email_user = User.new(@attr.merge(:email => address)) 
      invalid_email_user.should_not be_valid 
    end 
  end 

  it "should reject duplicate email addresses" do 
    # Put a user with given email address into the database. 
    User.create!(@attr) 
    user_with_duplicate_email = User.new(@attr) 
    user_with_duplicate_email.should_not be_valid 
  end 

  it "should reject email addresses identical up to case" do 
    upcased_email = @attr[:email].upcase 
    User.create!(@attr.merge(:email => upcased_email)) 
    user_with_duplicate_email = User.new(@attr) 
    user_with_duplicate_email.should_not be_valid
  end 
  
  it "should require a username" do
    no_username_user = User.new(@attr.merge(:username => ""))
    no_username_user.should_not be_valid
  end
  
  it "should reject usernames that are too long" do 
    long_username = "a" * 16
    long_username_user = User.new(@attr.merge(:username => long_username)) 
    long_username_user.should_not be_valid 
  end

  it "should reject duplicate username" do 
    User.create!(@attr) 
    user_with_duplicate_username = User.new(@attr) 
    user_with_duplicate_username.should_not be_valid 
  end 

  it "should reject username identical up to case" do 
    upcased_username = @attr[:username].upcase 
    User.create!(@attr.merge(:username => upcased_username)) 
    user_with_duplicate_username = User.new(@attr) 
    user_with_duplicate_username.should_not be_valid
  end 

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end    

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end 
    end

    describe "authenticate method" do

      it "should return nil on username/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:username], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an username address with no user" do
        nonexistent_user = User.authenticate("bar.foo", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on username/password match" do
        matching_user = User.authenticate(@attr[:username], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "notified_on_new_follower attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to notified_on_new_follower" do
      @user.should respond_to(:notified_on_new_follower)
    end

    it "should be notified_on_new_follower by default" do
      @user.should be_notified_on_new_follower
    end

    it "should be configurable to be notified_on_new_follower" do
      @user.toggle!(:notified_on_new_follower)
      @user.should_not be_notified_on_new_follower
    end
  end

  describe "replies associations" do

    before(:each) do
      @user = User.create(@attr)
      @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
      @micro_attr = { :content => "value for content" }

      @repl1 = @other_user.microposts.create!(@micro_attr)
      @user.replies << @repl1

      @repl2 = @other_user.microposts.create!(@micro_attr)
      @user.replies << @repl2
    end

    it "should have a replies attribute" do
      @user.should respond_to(:replies)
    end

    it "should belong the right parent user" do
      @repl1.user_id.should == @other_user.id
      @repl1.user.should == @other_user
    end

    it "should have an associated user to which it replies" do
      @repl1.replied_user_id.should == @user.id
      @repl1.replied_user.should == @user
    end

    it "should destroy associated replies" do
      @user.destroy
      [@repl1, @repl2].each do |reply|
        Micropost.find_by_id(reply.id).should be_nil
      end
    end
  end

  describe "microposts associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end

      it "should include the microposts of followed users" do
        followed = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end
    end
  end

  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end

    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)

      # Much more succint than '@user.following.include?(@followed).should be_true'
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "The destruction of follower should destroy associated following-follower" do
      @user.follow!(@followed)
      user_id = @user.id
      @user.destroy
      Relationship.find_by_followed_id(@followed.id).should be_nil
      Relationship.find_by_follower_id(user_id).should be_nil
    end

    it "The destruction of followed should destroy associated following-follower" do
      @user.follow!(@followed)
      followed_id = @followed.id
      @followed.destroy
      Relationship.find_by_followed_id(followed_id).should be_nil
      Relationship.find_by_follower_id(@user.id).should be_nil
    end

    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end 



# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  name                     :string(50)      not null
#  email                    :string(70)      not null
#  created_at               :datetime
#  updated_at               :datetime
#  encrypted_password       :string(50)
#  salt                     :string(100)
#  admin                    :boolean         default(FALSE), not null
#  username                 :string(15)      not null
#  notified_on_new_follower :boolean         default(TRUE), not null
#

