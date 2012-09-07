class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.integer  :question_id
      t.string :option
      t.boolean :is_right
      t.timestamps
    end
  end
end
