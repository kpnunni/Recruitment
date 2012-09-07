class CreateExamsInstructions < ActiveRecord::Migration
  def change
    create_table :exams_instructions do |t|
      t.integer  :exam_id
      t.integer  :instruction_id
      t.timestamps
    end
  end
end
