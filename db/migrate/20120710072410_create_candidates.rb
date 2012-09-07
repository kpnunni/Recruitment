class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.integer  :user_id
      t.string :name
      t.text :address
      t.string :phone1
      t.string :phone2
      t.string :technology
      t.string :certification
      t.string :skills
      t.string :resume_file_name
      t.string :resume_content_type
      t.string :resume_file_size
      t.integer :resume
      t.integer  :schedule_id
      t.timestamps
    end
  end
end
