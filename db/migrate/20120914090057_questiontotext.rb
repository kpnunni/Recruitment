class Questiontotext < ActiveRecord::Migration
  def up
    change_column :questions , :question, :text
  end

  def down
  end
end
