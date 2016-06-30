class TwitterJob::UserPostRetriever < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0,10,20,30,40,50) }
  queue_as :default


  def perform
    return if rate_limited?

    @client = TwitterClient
    @source = Source.twitter

    User.all.find_in_batches(batch_size: 5).each do |group|
      break if rate_limited?
      group.each do |user|
        next if user.posts.recently_created.any?;
        retrieve_post_info(user)
      end
    end
  end

  def retrieve_post_info(user)
    timeline = @client.user_timeline(user.username)
    init_user_for_source(user)

    timeline.each do |tweet|
      begin
        next if tweet.retweet?

        Post.create({
          user: user,
          source: @source,
          body: tweet.full_text,
          date: tweet.created_at,
          identifier: tweet.id
        })
      rescue => e
        Airbrake.notify(e)
      end
    end
  rescue Twitter::Error::TooManyRequests => e
    rate_limited(e)
  rescue Twitter::Error::NotFound => e
  rescue Twitter::Error::Unauthorized => e
  rescue => e
    Airbrake.notify(e)
  end

  def init_user_for_source(user)
    User.where(username: user.username, source: @source).first_or_create!
  end

  def rate_limited(e)
    sleep_time = (e.rate_limit.reset_in + 1.minute)/60 rescue 16
    Rails.cache.write('twitter-rate-limited', true, expires_in: sleep_time.minutes)
  end

  def rate_limited?
    Rails.cache.read('twitter-rate-limited').present?
  end

end
