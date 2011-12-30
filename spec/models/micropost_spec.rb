require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = Factory(:user)
    @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
    @attr = { :content => "value for content" }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "user associations" do

    before(:each) do
      @micropost = @user.microposts.create!(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe "replied_user associations" do

    before(:each) do
      @reply = @other_user.microposts.create!(@attr)
      @user.replies << @reply
    end

    it "should have a replied_user attribute" do
      @reply.should respond_to(:replied_user)
    end

    it "should belong the right parent user" do
      @reply.user_id.should == @other_user.id
      @reply.user.should == @other_user
    end

    it "should have an associated user to which it replies" do
      @reply.replied_user_id.should == @user.id
      @reply.replied_user.should == @user
    end

    it "should destroy associated replies" do
      @user.destroy
      Micropost.find_by_id(@reply.id).should be_nil
    end
  end

  describe "validations" do

    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.microposts.build(:content => "  ").should_not be_valid
    end

    it "should reject long content" do
      @user.microposts.build(:content => "a" * 141).should_not be_valid
    end
  end

  describe "from_users_in_same_group_of" do

    before(:each) do
      @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
      @third_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))

      @user_post  = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")

      @user.follow!(@other_user)
    end

    it "should have a from_users_in_same_group_of class method" do
      Micropost.should respond_to(:from_users_in_same_group_of)
    end

    it "should include the followed user's microposts" do
      Micropost.from_users_in_same_group_of(@user).should include(@other_post)
    end

    it "should include the user's own microposts" do
      Micropost.from_users_in_same_group_of(@user).should include(@user_post)
    end

    it "should not include an unfollowed user's microposts" do
      Micropost.from_users_in_same_group_of(@user).should_not include(@third_post)
    end
  end

  describe "replies to the current user" do

    before(:each) do
      @second_usr = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
      @third_usr = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))

      @user.follow!(@second_usr)
      @second_usr.follow!(@third_usr)

      @replyFrom1stTo2th = @user.microposts.create!(:content => "From first to second.")
      @second_usr.replies << @replyFrom1stTo2th

      @replyFrom3rdTo2nd = @third_usr.microposts.create!(:content => "From second to third.")
      @second_usr.replies << @replyFrom3rdTo2nd
    end

    it "should have a from_users_in_same_group_of class method" do
      Micropost.should respond_to(:from_users_in_same_group_of)
    end

    it "should include the followed user's replies" do
      Micropost.from_users_in_same_group_of(@user).should include(@replyFrom1stTo2th)
    end

    it "should include replies from followers" do
      Micropost.from_users_in_same_group_of(@second_usr).should include(@replyFrom1stTo2th)
    end

    it "should not include an unfollowed user's replies" do
      Micropost.from_users_in_same_group_of(@user).should_not include(@replyFrom3rdTo2nd)
    end
  end
end
# == Schema Information
#
# Table name: microposts
#
#  id              :integer         not null, primary key
#  content         :string(255)
#  user_id         :integer         not null
#  replied_user_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

