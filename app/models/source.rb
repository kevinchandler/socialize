class Source < ActiveRecord::Base
  has_many :posts
  attr_reader :name

  scope :reddit, -> { find_by_name('reddit') }
end
