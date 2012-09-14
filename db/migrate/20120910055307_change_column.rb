class ChangeColumn < ActiveRecord::Migration
  def up
     change_column :questions , :answer_id, :string
     add_column :exams, :complexity_id, :integer
     remove_column :roles_users , :created_at ,:updated_at
     remove_column :exams_instructions  , :created_at ,:updated_at
     remove_column :exams_questions  , :created_at ,:updated_at
     remove_column :roles_users , :created_at ,:updated_at
  end

  def down
  end
end
