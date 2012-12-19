class RecreateSettings < ActiveRecord::Migration
  def up
    drop_table :settings
    create_table :settings do |t|
      t.string :name
      t.string :status
      t.timestamps
    end
  end

  def down
  end
end
