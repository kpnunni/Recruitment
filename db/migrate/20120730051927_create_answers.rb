class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :candidate_id
      t.integer :questions_id
      t.string :answer
      t.time :time_taken
      t.timestamps
    end
  end
end
