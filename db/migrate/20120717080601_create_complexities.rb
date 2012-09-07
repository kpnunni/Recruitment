class CreateComplexities < ActiveRecord::Migration
  def change
    create_table :complexities do |t|
      t.string :complexity
      t.timestamps
    end
  end
end
