class AddMetaInfoToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :meta_info, :text
    add_index :posts, :meta_info
  end
end
