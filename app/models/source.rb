class Source < ActiveRecord::Base
  validates_uniqueness_of :name

  has_many :posts
  has_many :users
  attr_reader :name

  scope :reddit, -> { find_by_name('reddit') }
  scope :twitter, -> { find_by_name('twitter') }
end
