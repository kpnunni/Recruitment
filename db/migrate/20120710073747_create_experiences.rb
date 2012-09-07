class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.integer :candidate_id
      t.date :from_date
      t.date :to_date
      t.string :experience_in
      t.string :experience_from
      t.timestamps
    end
  end
end
