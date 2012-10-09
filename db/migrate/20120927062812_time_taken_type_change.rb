class TimeTakenTypeChange < ActiveRecord::Migration
  def up
        change_column :answers , :time_taken, :integer
  end

  def down
  end
end
