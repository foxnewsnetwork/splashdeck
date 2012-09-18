class CreateStickies < ActiveRecord::Migration
  def change
    create_table :stickies do |t|
      t.integer :user_id
      t.integer :page_id
      t.string :type
      t.string :content
      t.string :metadata

      t.timestamps
    end
  end
end
