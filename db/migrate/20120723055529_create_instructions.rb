class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.string :instruction
      t.timestamps
    end
  end
end
