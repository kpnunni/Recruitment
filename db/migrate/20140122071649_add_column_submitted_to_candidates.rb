class AddColumnSubmittedToCandidates < ActiveRecord::Migration
  def up
    add_column :candidates ,:submitted ,:Boolean, default: false
  end

  def down
    remove_column :candidates ,:submitted
  end
end
