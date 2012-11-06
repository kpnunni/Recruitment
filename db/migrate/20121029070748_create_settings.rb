class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.boolean :auto_result
      t.timestamps
    end
  end
end
