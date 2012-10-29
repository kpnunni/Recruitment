class Cutoff < ActiveRecord::Migration
  def up
    add_column :categories ,:cutoff,:Integer
  end

  def down
  end
end
