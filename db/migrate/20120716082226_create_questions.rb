class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer  :type_id
      t.integer  :category_id
      t.integer  :complexity_id
      t.integer :answer
      t.string :question
      t.time :allowed_time
      t.string :created_by
      t.timestamps
    end
  end
end
