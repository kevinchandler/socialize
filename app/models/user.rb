class User < ActiveRecord::Base
  validates_uniqueness_of :username, scope: :source
  validates_presence_of [:username, :source, :first_encountered]
end
