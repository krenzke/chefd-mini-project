require 'dotenv'
Dotenv.load!

require 'sequel'
require 'twitter'
require './parser.rb'
require './store.rb'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
end

# Set up our inter-thread communications
parse_queue = Queue.new
storage_queue = Queue.new

# Parsing threads/workers
parse_threads = 3.times.map do |i|
  Thread.new do
    parser = Parser.new(parse_queue, storage_queue)
    parser.run
  end
end

# Storage thread/worker
store_thread = Thread.new do
  store = Store.new(storage_queue)
  store.run
end

# 1. Fetch data from Twitter (or similar data source)
# 2. Parse data
# 3. Store data
since_id = Store.last_id
puts "Starting Twitter fetch from #{since_id || 'no id'}"
while true
  tweets = client.search('chefd', since_id: since_id)
  puts "Fetched #{tweets.count} tweets"
  tweets.each do |tweet|
    parse_queue << tweet
    since_id = tweet.id if (!since_id || tweet.id > since_id)
  end
  sleep 1
end
