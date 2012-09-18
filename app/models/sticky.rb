class Sticky < ActiveRecord::Base
  attr_accessible :content, :metadata, :page_id, :type, :user_id
  
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
