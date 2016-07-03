class UsernameController < ApplicationController

  def search
    posts = retrieve_posts(params[:username])
    render status: :ok, json: { posts: posts }
  end

  private

  def retrieve_posts(username)
    reddit_posts = RedditJob::UserPostRetriever.new.perform username
    twitter_posts = TwitterJob::UserPostRetriever.new.perform username
    { reddit: reddit_posts, twitter: twitter_posts }
  end
end
