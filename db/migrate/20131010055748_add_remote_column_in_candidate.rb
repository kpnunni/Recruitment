class AddRemoteColumnInCandidate < ActiveRecord::Migration
  def up
    add_column :schedules ,:remote ,:Boolean, default: 0
  end

  def down
    remove_column :schedules ,:remote
  end
end
