class MicropostsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def index
    @microposts = current_user.microposts.paginate(:page => params[:page])
  end

  def create
    content = params[:micropost][:content]
    username = nil
    match_data = Micropost.reply_regex.match(content) || Micropost.whisper_regex.match(content)

    # If need be, filter out the username from the content.
    if (!match_data.nil?)
      username = match_data[1]
      params[:micropost][:content] = match_data[2]
    end

    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save

      replied_user = User.find_by_username(username)
      replied_user.replies << @micropost unless(match_data.nil? || !current_user.following?(replied_user))

      redirect_to root_path, :flash => { :success => "Micropost created!" }
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end

  private

    def authorized_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
    end
end
