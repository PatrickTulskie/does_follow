require 'net/http'
require 'open-uri'
require "rexml/document"

def is_following(user, test_follower)
  # HTTP Pulling Variables
  content = ""
  source = "http://twitter.com/statuses/friends/#{test_follower}.xml"
  # Loop setup variables
  round_count = 0 # Keeps track of the number of users found on a given page.
  continue = true
  page_number = 1 # Keeps track of the page number we're on.
  # Final variable
  answer = false
  
  while continue
    open("#{source}?page=#{page_number}", :http_basic_authentication => [@twitter_name, @twitter_password]) do |s| content = s.read end
    following_data = REXML::Document.new(content)

    following_data.elements.each('users/user/screen_name') do |friend|
      # Check to see if the friend is the user
      answer = true if friend.text.casecmp(user) == 0
      
      # Keep track of how many we found in this round
      round_count += 1
    end
    
    # Let's bail out here if we got an answer or keep going if not.
    if answer == true
      continue = false
    else
      # Jump out if we saw no friends in the latest page
      continue = round_count > 0 ? true : false
      round_count = 0
      page_number += 1
    end
    
  end
  
  return answer
  
end

# Some globals
@twitter_name = "" # Whatever Twitter user you want to authenticate with
@twitter_password = "" # Password for the above user

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
  puts is_following(user, test_follower) ? "OH YEAH!" : "Nahhh."
end