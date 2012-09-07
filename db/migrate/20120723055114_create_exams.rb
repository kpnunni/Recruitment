class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.string :name
      t.string :description
      t.string :created_by
      t.string :modified_by
      t.integer :no_of_question
      t.integer :total_time
      t.timestamps
    end
  end
end
