class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_email
      t.string :password
      t.string :salt
      t.boolean :isDelete
      t.boolean :isAlive
      t.timestamps
    end
  end
end
