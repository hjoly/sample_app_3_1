class Micropost < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user

  belongs_to :replied_user, :class_name => "User", :foreign_key => "replied_user_id"

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => "microposts.created_at DESC"

  def self.reply_regex
    /\A@([\w+]+[\-.][\w+]+) (([\S+]+[\s+]*)+)/
  end
  
  def self.whisper_regex
    /\Ad ([\w+]+[\-.][\w+]+) (([\S+]+[\s+]*)+)/
  end

  def self.from_users_in_same_group_of(user)
    select("DISTINCT microposts.*").
      joins("LEFT OUTER JOIN relationships r ON microposts.user_id = r.followed_id").
      where("r.follower_id = :user_id OR microposts.user_id = :user_id OR microposts.replied_user_id = :user_id",
            { :user_id => user })

    # query = %(SELECT DISTINCT m.*
    #             FROM microposts m LEFT OUTER JOIN relationships r
    #               ON m.user_id = r.followed_id 
    #            WHERE r.follower_id = #{user.id}
    #               OR m.user_id = #{user.id}
    #               OR m.replied_user_id = #{user.id}
    #            ORDER BY m.created_at DESC)
    # Micropost.find_by_sql(query)
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

