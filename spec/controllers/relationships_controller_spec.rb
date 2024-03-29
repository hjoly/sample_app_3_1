require 'spec_helper'

describe RelationshipsController do

  describe "access control" do

    it "should require signin for create" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should require signin for destroy" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
    end

    it "should create a relationship without notifying the followed that don't require it" do
      @followed.toggle!(:notified_on_new_follower)
      lambda do
        post :create, :relationship => { :followed_id => @followed }
        response.should be_redirect
        ActionMailer::Base.deliveries.should be_empty
      end.should change(Relationship, :count).by(1)
    end

    it "should create a relationship" do
      lambda do
        # ":relationship => { :followed_id => @followed }" simulates "<%= f.hidden_field :followed_id %>".
        post :create, :relationship => { :followed_id => @followed }
        response.should be_redirect
        ActionMailer::Base.deliveries.last.to.should == [@followed.email]
      end.should change(Relationship, :count).by(1)
    end

    it "should create a relationship using Ajax and notify it to the followed via an email." do
      lambda do
        xhr :post, :create, :relationship => { :followed_id => @followed }
        response.should be_success
        ActionMailer::Base.deliveries.last.to.should == [@followed.email]
      end.should change(Relationship, :count).by(1)
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end

    it "should destroy a relationship" do
      lambda do
        delete :destroy, :id => @relationship
        response.should be_redirect
      end.should change(Relationship, :count).by(-1)
    end

    it "should destroy a relationship using Ajax" do
      lambda do
        xhr :delete, :destroy, :id => @relationship
        response.should be_success
      end.should change(Relationship, :count).by(-1)
    end
  end
end
