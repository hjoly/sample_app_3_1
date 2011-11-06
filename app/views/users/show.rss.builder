xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.name.possessive} Microposts"
    xml.description "All that I can think of"
    xml.link "#{user_path}.rss"

    for micropost in @user.microposts        
      xml.item do
        xml.title micropost.content
        xml.pubDate micropost.created_at
        xml.link "#{user_path}.rss"
        xml.guid "#{user_path}.rss"
      end
    end
  end
end