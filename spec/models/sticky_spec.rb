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

require 'spec_helper'
require 'factories'

describe Sticky do
	describe "sanitize" do
		before :each do
			@target = "<textarea value='faggot'>asdf</textarea>"
			@expected = "&lt;textarea value=&apos;faggot&apos;&gt;asdf&lt;/textarea&gt;"
		end # before each
		it "should sanitize out html" do
			Sticky.sanitize(@target).should eq @expected
		end # it
	end # sanitize
end # Sticky
