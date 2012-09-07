class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :exam_id
      t.date :sh_date
      t.time :sh_time
      t.timestamps
    end
  end
end
