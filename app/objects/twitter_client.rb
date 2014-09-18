class TwitterClient
  
  attr_accessor :client
  MAX_RETRIES = 3
  
  def initialize
    self.client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "H3SHzzDN4ULN8PmMHgFLxb3BQ"
      config.consumer_secret     = "j1CTE9T0fqLK4Ygn9ZHwokplS7PZWyZzRcU1I6nhRIZMZ9QWdT"
    end
  end
  
  def tweets_from(username)
    get_all_tweets(username)
  end
  
  def common_followers(user1, user2)
    followers1 = client.followers(user1, {count: 200}).to_a.map(&:screen_name)
    followers2 = client.followers(user2, {count: 200}).to_a.map(&:screen_name)
    
    followers1 & followers2
  end
  
    
  private
  
    # Progressively build a results array for a Twitter API call while backing off when reaching the rate
    # limit.
    def get_cursor_results(action, items, *args)
      result = []
      next_cursor = -1
      until next_cursor == 0
        begin
          t = @client.send(action, args[0], {:cursor => next_cursor})
          puts t.attrs
          result = result + t.attrs[items.to_sym]
          next_cursor = t.attrs[:next_cursor]
        rescue Twitter::Error::TooManyRequests => error
          puts "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds..."
          sleep error.rate_limit.reset_in
          retry
        end
      end
      return result
    end    
  
    # Keep retrying the Twitter API call for MAX_RETRIES when the client has been rate limited
    def with_retry #block
      num_attempts = 0
      begin
        num_attempts += 1
        yield
      rescue Twitter::Error::TooManyRequests => error
        if num_attempts <= MAX_RETRIES
            # NOTE: Your process could go to sleep for up to 15 minutes but if you
            # retry any sooner, it will almost certainly fail with the same exception.
          puts "RETRY in #{error.rate_limit.reset_in}"
          sleep error.rate_limit.reset_in
          retry
        else
          raise
        end
      end
    end

    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield(max_id)
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end

    # Get all tweets for a user, 200 at a time - a restriction of the Twitter API
    def get_all_tweets(user)
      collect_with_max_id do |max_id|
        options = {:count => 200, :include_rts => true}
        options[:max_id] = max_id unless max_id.nil?
        client.user_timeline(user, options)
      end
    end  
end