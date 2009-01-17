require 'rubygems'
require 'httparty'

class Twitter
  include HTTParty
  base_uri 'twitter.com'
  basic_auth 'user_name', 'password' # Edit these to match your own credentials.
  default_params :output => 'xml'
  format :xml

  def self.user_details(user_name)
    get("/users/show/#{user_name}")
  end
  
  def self.followers_for(user_name, page_number=1)
    get("/statuses/followers/#{user_name}.xml", :query => {:page => page_number})["users"]
  end
  
  def self.following_list_for(user_name, page_number=1)
    get("/statuses/friends/#{user_name}.xml", :query => {:page => page_number})["users"]
  end
  
  def self.follower_count(user_name)
    self.user_details(user_name)["user"]["followers_count"]
  end
  
  def self.following_count(user_name)
    self.user_details(user_name)["user"]["friends_count"]
  end
  
  def self.does_follow(user, test_follower)
    # Prepare for the searching loop
    page = 1 # Keeps track of the page number we're on.
    answer = false # Is that your final answer?

    # Collect some decision data
    user_followers = self.follower_count(user).to_i
    test_following = self.following_count(test_follower).to_i
    query_self = user_followers < test_following ? true : false
    
    while !answer
      name_list = query_self ? self.followers_for(user, page) : name_list = self.following_list_for(test_follower, page)
      break if name_list.length == 0
      
      name_list.each do |current|
        answer = true if current["screen_name"].casecmp(query_self ? test_follower : user) == 0
      end
      page += 1
    end
    return answer  
  end

end

# Set this for your copy of the script.
default_user = "PatrickTulskie" # If only one name is given this is what it will use

# Handles the ARGS and decides whether or not to use the default user
if ARGV.nil? || ARGV.empty? || ARGV.length > 2
  puts "Error: Not enough or too many users."
else
  case ARGV.length
  when 1:
    user = default_user
    test_follower = ARGV[0]
  when 2:
    user = ARGV[0]
    test_follower = ARGV[1]
  end
  puts Twitter.does_follow(user, test_follower) ? "OH YEAH!" : "Nahhh."
end
