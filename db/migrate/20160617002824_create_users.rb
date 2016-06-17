class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :source
      t.date :first_encountered
    end
  end
end
