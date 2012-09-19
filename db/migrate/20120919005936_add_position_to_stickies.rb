class AddPositionToStickies < ActiveRecord::Migration
  def change
    add_column :stickies, :width, :int
    add_column :stickies, :height, :int
    add_column :stickies, :x, :decimal, :scale => 3, :precision => 10
    add_column :stickies, :y, :decimal, :scale => 3, :precision => 10
  end
end
