class Post < ActiveRecord::Base
  belongs_to :source
  belongs_to :user
  validates_uniqueness_of :title, :body, scope: [:source, :user]
end
