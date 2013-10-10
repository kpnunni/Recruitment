class AddRemoteColumnInCandidate < ActiveRecord::Migration
  def up
    add_column :schedules ,:remote ,:Boolean, default: true
  end

  def down
    remove_column :schedules ,:remote
  end
end
