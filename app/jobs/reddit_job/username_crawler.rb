class RedditJob::UsernameCrawler < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable

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
  end

  def create_user(username)
    User.create({ username: username, source: 'reddit', first_encountered: Date.today })
  end
end