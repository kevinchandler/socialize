class User < ActiveRecord::Base
  validates_uniqueness_of :username, scope: :source
  validates_presence_of [:username, :source]

  after_create :check_first_encountered

  has_many :posts
  belongs_to :source

  scope :reddit, -> { where(source: Source.reddit) }
  scope :twitter, -> { where(source: Source.twitter) }

  def check_first_encountered
    return unless first_encountered.nil?
    first_encountered = Date.today
    save
  end
end
