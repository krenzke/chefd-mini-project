class Parser
  attr_accessor :input_queue, :output_queue
  def initialize(input_queue, output_queue)
    @input_queue = input_queue
    @output_queue = output_queue
  end

  def run
    while true
      tweet = input_queue.pop
      output_queue << parse_tweet(tweet)
    end
  end

  def parse_tweet(tweet)
    {
      tweet: {
        id: tweet.id,
        text: tweet.text,
        created_at: tweet.created_at,
        user_id: tweet.user.id,
        retweet_count: tweet.retweet_count,
        favorite_count: tweet.favorite_count,
      },
      user: {
        id: tweet.user.id,
        screen_name: tweet.user.screen_name,
        followers_count: tweet.user.followers_count,
        friends_count: tweet.user.friends_count,
      },
      hashtags: tweet.hashtags.map do |hashtag|
        {
          tag: hashtag.text,
          tweet_id: tweet.id,
        }
      end
    }
  end
end
