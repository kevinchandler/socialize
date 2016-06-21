class ChangeUsersAddIndexToSource < ActiveRecord::Migration
  def change
    add_index :users, :source
  end
end
