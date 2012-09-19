class RenameTypeToCategoryStickies < ActiveRecord::Migration
  def up
  	rename_column :stickies, :type, :category
  end

  def down
  	rename_column :stickies, :category, :type
  end
end
