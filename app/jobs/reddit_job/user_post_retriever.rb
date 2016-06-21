class RedditJob::UserPostRetriever < ActiveJob::Base
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options retry: false

  recurrence { hourly }
  queue_as :default

  def perform
    User.reddit.find_in_batches(batch_size: 5).each do |group|
      group.each { |user| retrieve_post_info(user) }
    end
  end

  def retrieve_post_info(user)
    username = user.username
    url = "https://reddit.com/u/#{username}.json"
    res = HTTParty.get(url)
    return unless res && res['data'] && res['data']['children']
    res['data']['children'].each do |post|
      post = post['data']
      next unless (post['author'] == username) && post['body']
      identifier = generate_identifier(post)

      begin
        Post.create({
          user: user,
          source: Source.reddit,
          title: post['title'],
          body: post['body'],
          date: Time.at(post['created']),
          identifier: identifier
        })
      rescue => e
        Airbrake.notify(e)
      end

    end
  rescue => e
    puts e
    Airbrake.notify(e)
  end

  def generate_identifier(post)
    hash = post['body'] && "#{post['author']}:#{post['body']}" || Time.now.to_s
    Digest::SHA1.hexdigest(hash)
  end

end
