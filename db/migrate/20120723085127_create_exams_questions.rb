class CreateExamsQuestions < ActiveRecord::Migration
  def change
    create_table :exams_questions do |t|
      t.integer  :exam_id
      t.integer  :question_id
      t.timestamps
    end
  end
end
