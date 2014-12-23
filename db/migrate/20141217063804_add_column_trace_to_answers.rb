class AddColumnTraceToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers ,:trace ,:string
  end
end
