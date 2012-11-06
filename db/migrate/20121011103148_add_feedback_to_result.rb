class AddFeedbackToResult < ActiveRecord::Migration
  def change
    add_column :recruitment_tests ,:feedback,:text
  end
end
