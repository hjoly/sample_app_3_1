namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_relationships
    make_microposts
  end
end
 
def make_users
    admin = User.create!(:name => "Example User",
                 	 :email => "example@railstutorial.org",
                         :username => "example.tut",
                 	 :password => "foobar",
                 	 :password_confirmation => "foobar",
                         :notified_on_new_follower => true)
    admin.toggle!(:admin)
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      username = "example-#{n+1}tut"
      password  = "password"
      notified_on_new_follower = true
      User.create!(:name => name,
                   :email => email,
                   :username => username,
                   :password => password,
                   :password_confirmation => password,
                   :notified_on_new_follower => notified_on_new_follower)
    end
end

def make_relationships
    users = User.all
    user = users.first
    following = users[1..50]
    followers = users[3..40]
    following.each { |followed| user.follow!(followed) }
    followers.each { |follower| follower.follow!(user) }
end

# Must be called after make_relationships
def make_microposts
    random = Random.new 1234

    # It's better to start with the 'users' array and access its elements than to use
    # User.find(<index>) which instantiates a new object every time => avoids objects proliferations.
    users = User.all

    user = users[random.rand(1..6) - 1]    
    user.microposts.create!(:content => Faker::Lorem.sentence(5))

    (2..300).each do
        user = users[random.rand(1..6) - 1]
        content = Faker::Lorem.sentence(5)

        followed_id = random.rand(1..6)

        # A user can't reply to another user that he's not following
        if ( user.following?(users[followed_id - 1]) )

            followed_user = users[followed_id - 1]

            # It's better to put the new micro in a var that can be referred by both the user 
            # (and the replied user if it'll turn into a reply).  That way, we ensure that both users refer to the same micro.
            # Remember: micro and user.microposts.last are distinct objects (although they both share the same micro id)!
            micro = user.microposts.create!(:content => content)

            followed_user.replies << micro
        else
            user.microposts.create!(:content => content)
        end
    end
end
