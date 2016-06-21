class AddSourceReferenceToUser < ActiveRecord::Migration
  def change
    remove_column :users, :source
    add_column :users, :source_id, :integer
    add_index :users, :source_id
  end
end
