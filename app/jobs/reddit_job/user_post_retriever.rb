class RedditJob::UserPostRetriever < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options retry: false

  queue_as :default

  def perform(username)
    retrieve_post_info(username)
  end

  def retrieve_post_info(username)
    url = "https://reddit.com/u/#{username}.json"
    res = HTTParty.get(url)
    user_posts = []
    return user_posts unless res && res['data'] && res['data']['children']
    res['data']['children'].each do |post|
      begin
        post = post['data']
        next unless post['author'].downcase == username.downcase && post['body']

        user_posts << {
          username: username,
          title: post['title'],
          body: post['body'],
          date: Time.at(post['created']),
          subreddit: post['subreddit']
        }
      rescue URI::InvalidURIError => e
      rescue => e
        puts e
        Airbrake.notify(e)
      end
    end
  ensure
    return user_posts
  end
end
