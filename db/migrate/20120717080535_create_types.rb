class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      t.string :question_type
      t.timestamps
    end
  end
end
