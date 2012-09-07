class CreateRecruitmentTests < ActiveRecord::Migration
  def change
    create_table :recruitment_tests do |t|
      t.integer :candidate_id
      t.boolean :is_completed
      t.datetime :completed_on
      t.integer :right_answers
      t.integer :no_of_question_attended
      t.float :mark_percentage
      t.string  :is_passed
      t.string :comments
      t.timestamps
    end
  end
end
