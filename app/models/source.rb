class Source < ActiveRecord::Base
  has_many :posts
  has_many :users
  attr_reader :name

  scope :reddit, -> { find_by_name('reddit') }
end
