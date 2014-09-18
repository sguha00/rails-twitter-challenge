class TwitterController < ApplicationController
  
  def tweets
    user = params[:user]
    tweets = twitter_client.tweets_from(user).map {|t| {id: t.id, text: t.text}}
    render json: tweets
  rescue Twitter::Error::NotFound
    render json: {error: "User not found"}, status: 404
  rescue Twitter::Error::TooManyRequests => error
    render json: {error: "Rate limit error, try again in #{error.rate_limit.reset_in} seconds"}, status: 500
  rescue Twitter::Error => error
    render json: {error: error.message}, status: 500
  end
  
  def followers
    user1 = params[:user1]
    user2 = params[:user2]
    followers = twitter_client.common_followers(user1, user2)
    render json: followers
  rescue Twitter::Error::NotFound
    render json: {error: "User not found"}, status: 404
  rescue Twitter::Error::TooManyRequests => error
    render json: {error: "Rate limit error, try again in #{error.rate_limit.reset_in} seconds"}, status: 500
  rescue Twitter::Error => error
    render json: {error: error.message}, status: 500
  end
  
  private
    def twitter_client
      @client ||= TwitterClient.new
    end
  
end
