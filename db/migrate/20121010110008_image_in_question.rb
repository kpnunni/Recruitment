class ImageInQuestion < ActiveRecord::Migration
  def up
      add_column :questions  , :question_image_file_name, :string
      add_column :questions  , :question_image_content_type, :string
      add_column :questions  , :question_image_file_size, :string
      add_column :questions  , :question_image, :integer
  end

  def down
      remove_column :questions  , :question_image_file_name, :string
      remove_column :questions  , :question_image_content_type, :string
      remove_column :questions  , :question_image_file_size, :string
      remove_column :questions  , :question_image, :integer
  end
end
