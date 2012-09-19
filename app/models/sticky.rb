# == Schema Information
#
# Table name: stickies
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  page_id    :integer
#  category   :string(255)
#  content    :string(255)
#  metadata   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  width      :integer
#  height     :integer
#  x          :decimal(10, 3)
#  y          :decimal(10, 3)
#

class Sticky < ActiveRecord::Base
  attr_accessible :content, :metadata, :category, :width, :height, :x, :y
  
  before_save do |sticky|
  	sticky.content = Sticky.sanitize sticky.content
  	sticky.metadata = Sticky.sanitize sticky.metadata
  end # before_save
  
  belongs_to :page
  belongs_to :user
  
  def self.sanitize string
  	string.gsub /[<>'"]/, { 
  		"<" => "&lt;" ,
  		">" => "&gt;" ,
  		"'" => "&apos;" ,
  		'"' => "&quot;"
  	} # gsub
  end # sanitize
  
end # Sticky
