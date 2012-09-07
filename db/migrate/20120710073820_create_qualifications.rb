class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.integer :candidate_id
      t.string :qualification_in
      t.string :qualification_from
      t.date :from_date
      t.date :to_date
      t.float :mark_percentage
      t.string :comments
      t.timestamps
    end
  end
end
