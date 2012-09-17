class Datetimefield < ActiveRecord::Migration
  def up
    change_column :schedules , :sh_date, :datetime
    remove_column :schedules  , :sh_time
  end

  def down
  end
end
