require 'spec_helper'

describe "Microposts" do

  before(:each) do
    @user = Factory(:user)
    visit signin_path
    fill_in :username, :with => @user.username
    fill_in :password, :with => @user.password
    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new micropost with empty content" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end
    end

    describe "success" do

      before(:each) do
        @content = "Lorem ipsum dolor sit amet"
      end

      it "should make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => @content
          click_button
          response.should have_selector("a", :id => "user", :content => @user.name)
          response.should have_selector("span.content", :content => @content)
        end.should change(Micropost, :count).by(1)
      end

      describe "as a reply" do

        before(:each) do
          @other_user = Factory(:user, :email => Factory.next(:email), :username => Factory.next(:username))
          @reply_str = "@#{@other_user.username} " + @content
        end

        it "should make a simple micro from an unfolled user" do
          lambda do
            visit root_path
            fill_in :micropost_content, :with => @reply_str
            click_button
            response.should have_selector("a", :id => "user", :content => @user.name)
            response.should_not have_selector("a", :id => "reply", :content => "@#{@other_user.username}")
            response.should have_selector("span.content", :content => @content)
          end.should change(Micropost, :count).by(1)
        end

        it "should make a new reply to a followed user" do
          @user.follow! @other_user
          lambda do
            visit root_path
            fill_in :micropost_content, :with => @reply_str
            click_button
            response.should have_selector("a", :id => "user", :content => @user.name)
            response.should have_selector("a", :id => "reply", :content => "@#{@other_user.username}")
            response.should have_selector("span.content", :content => @content)
          end.should change(Micropost, :count).by(1)
        end
      end
    end
  end
end
