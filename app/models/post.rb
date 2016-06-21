class Post < ActiveRecord::Base
  belongs_to :source
  belongs_to :user
  validates_uniqueness_of :identifier, scope: [:source, :user]
end
