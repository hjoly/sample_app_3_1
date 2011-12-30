require 'digest'

class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :username, :password, :password_confirmation

  has_many :microposts, :dependent => :destroy

  has_many :replies, :foreign_key => "replied_user_id", :class_name => "Micropost", :dependent => :destroy

  # The following pair defines a 'following' relation: the list of users beeing followed by this user.
  # The class_name is implicit (Relationship), foreign_key (Relationship.follower_id points to myself)
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  # The target of the relation: 
  # following (= someone we're following), through (via the relationship class), source (relationship.followed)
  has_many :following, :through => :relationships, :source => :followed

  # The following pair defines a 'followers' relation: the users that follow this user.
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower

  validates :name,  :presence => true,
                    :length => { :maximum => 50 }

  username_regex = /\A[\w+]+[\-.]?[\w+]*/i
  validates :username, :presence => true, 
                       :format => { :with => username_regex },
                       :length => { :maximum => 15 },
                       :uniqueness => { :case_sensitive => false }

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }

  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }

  before_save :encrypt_password

  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def feed
    Micropost.from_users_in_same_group_of(self)
  end

  class << self
    def authenticate(username, submitted_password)
      user = find_by_username(username)
      (user && user.has_password?(submitted_password))? user : nil
    end

    def authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end
  end

  private

   def encrypt_password
     self.salt = make_salt if new_record?
     self.encrypted_password = encrypt(password)
   end

   def encrypt(string)
     secure_hash("#{salt}--#{string}")
   end

   def make_salt
     secure_hash("#{Time.now.utc}--#{password}")
   end

   def secure_hash(string)
     Digest::SHA2.hexdigest(string)
   end
end



# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(50)      not null
#  email              :string(70)      not null
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(50)
#  salt               :string(100)
#  admin              :boolean         default(FALSE), not null
#  username           :string(15)      not null
#

