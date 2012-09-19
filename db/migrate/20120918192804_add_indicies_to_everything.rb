class AddIndiciesToEverything < ActiveRecord::Migration
  def change
  	add_index :pages, :user_id
  	add_index :stickies, :user_id
  	add_index :stickies, [:page_id, :user_id]
  end
end # Indicies
