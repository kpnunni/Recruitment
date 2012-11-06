class Addcreateby < ActiveRecord::Migration
  def up
      add_column :schedules  , :created_by, :string
      add_column :schedules  , :updated_by, :string
      add_column :questions  , :updated_by, :string
  end

  def down
  end
end
