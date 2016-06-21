class RedditJob::UserPostRetriever < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }
  queue_as :default

  def perform
    users = User.reddit
    users.each { |user| retrieve_post_info(user) }
  end

  def retrieve_post_info(user)
    username = user.username
    url = "https://reddit.com/u/#{username}.json"
    res = HTTParty.get(url)
    return unless res && res['data'] && res['data']['children']

    res['data']['children'].each do |post|
      post = post['data']
      next unless post['author'] == username
      identifier = generate_identifier(post)
      next if Post.where(identifier: identifier, user: user)

      Post.create({
        user: user,
        source: Source.reddit,
        body: post['body'],
        date: Time.at(post['created']),
        identifier: identifier
      })

    end
  rescue => e
    # TODO
  end

  def generate_identifier(post)
    body = post['body'] || Time.now.to_s
    Digest::SHA1.hexdigest(body)
  end

end
