class RedditJob::UsernameCrawler < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options retry: false

  recurrence { minutely }
  queue_as :default

  def perform
    url = Source.reddit.url
    usernames = crawl_for_usernames(url)

    usernames.each { |un| create_user(un) }
  end

  def crawl_for_usernames(url)
    res = HTTParty.get(url)
    res['data']['children'].map { |post| post['data']['author'] }
  rescue => e
    Airbrake.notify(e)
  end

  def create_user(username)
    User.create({ username: username, source: Source.reddit, first_encountered: Date.today })
  end
end
