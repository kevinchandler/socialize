class Post < ActiveRecord::Base
  belongs_to :source
  belongs_to :user
  validates_uniqueness_of :identifier, scope: [:source, :user]
  validates_presence_of :body

  scope :reddit, -> { where(source: Source.reddit) }
  scope :twitter, -> { where(source: Source.twitter) }
  scope :recently_created, -> { where('created_at >= ?', 3.days.ago) }

end
