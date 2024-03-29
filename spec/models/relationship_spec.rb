require 'spec_helper'

describe Relationship do

  before(:each) do
    @follower = Factory(:user)
    @followed = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))

    @relationship = @follower.relationships.build(:followed_id => @followed.id)
  end

  it "should create a new instance given valid attributes" do
    @relationship.save!
  end

  describe "follow methods" do

    # Why do we need to do a save [?]
    before(:each) do
      @relationship.save
    end

    it "should have a follower attribute" do
      @relationship.should respond_to(:follower)
    end

    it "should have the right follower" do
      @relationship.follower.should == @follower
    end

    it "should have a followed attribute" do
      @relationship.should respond_to(:followed)
    end

    it "should have the right followed user" do
      @relationship.followed.should == @followed
    end
  end

  describe "validations" do

    it "should require a follower_id" do
      @relationship.follower_id = nil
      @relationship.should_not be_valid
    end

    it "should require a followed_id" do
      @relationship.followed_id = nil
      @relationship.should_not be_valid
    end
  end
end
# == Schema Information
#
# Table name: relationships
#
#  id          :integer         not null, primary key
#  follower_id :integer         not null
#  followed_id :integer         not null
#  created_at  :datetime
#  updated_at  :datetime
#

