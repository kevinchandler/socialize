class TwitterJob::UserPostRetriever < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options retry: false

  queue_as :default

  MAX_TIMELINE_TWEETS = 200

  def perform(username)
    return [] if rate_limited?
    user_tweets = retrieve_post_info(username)
  end

  def retrieve_post_info(username)
    timeline = TwitterClient.user_timeline(username, { count: MAX_TIMELINE_TWEETS } )
    user_tweets = []

    timeline.each do |tweet|
      begin
        obj = {
          tweet_text: tweet.full_text,
          tweet_id: tweet.id,
          is_retweet: tweet.retweet?,
          reply_to_screenname: -> {
            tweet.reply? ? tweet.reply_to_screenname.to_s : nil
          }.call,
          favorite_count: tweet.favorite_count,
          retweet_count: tweet.retweet_count,
          geo: -> {
            tweet.geo? ? tweet.geo.to_s : nil
          }.call,
          metadata: -> {
            tweet.metadata? ? tweet.metadata : nil
          }.call,
          date: tweet.created_at
        }
        user_tweets << obj
      rescue => e
        Airbrake.notify(e)
        next
      end
    end
  rescue Twitter::Error::TooManyRequests => e
    rate_limited(e)
  rescue Twitter::Error::NotFound => e
    # no posts found for user
  rescue Twitter::Error::Unauthorized => e
  rescue => e
    Airbrake.notify(e)
  ensure
    return user_tweets
  end

  def rate_limited(e)
    sleep_time = (e.rate_limit.reset_in + 1.minute)/60 rescue 16
    Rails.cache.write('twitter-rate-limited', true, expires_in: sleep_time.minutes)
  end

  def rate_limited?
    Rails.cache.read('twitter-rate-limited').present?
  end

end
