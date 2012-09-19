require 'spec_helper'
require 'factories'
describe StickiesController do
	describe "not logged in" do
		before :each do
			@user = User.create :email => "jf024h024@fja.con", :password => "jr2023j024tt"
			@page = @user.pages.create Factory.next(:page)
		end # before each
		describe "show" do
			it "SHOULD HAVE IT'S OWN TESTS INSTEAD OF DEPENDING ON THE CREATE ONE"
		end # show
		describe "update" do
			before :each do
				@sticky = @page.stickies.create Factory.next(:sticky)
				@sticky_data = Factory.next(:sticky)
				@update = lambda { xhr :put, :update, :id => @sticky.id, :page_id => @page.id, :sticky => @sticky_data  }
			end # before each
			Sticky.attr_accessible[:default].each do |field|
				next if field.blank?
				it "should change the field #{field}" do
					key = field.to_sym
					@update.should change(lambda { Sticky.find( @sticky.id )[key]}, :call).from( @sticky[key] ).to( @sticky_data[key] )
				end # it
			end # # each field
			describe "anonymity collapse" do
				before :each do
					@sticky.user_id = @user.id
					@sticky.save!
				end # before each		
				Sticky.attr_accessible[:default].each do |field|
					next if field.blank?
					it "should not change the field #{field}" do
						key = field.to_sym
						@update.should_not change(lambda { Sticky.find( @sticky.id )[key]}, :call)
					end # it
				end # each field	
			end # anonymity collapse
		end # update
		describe "index" do
			before :each do
				10.times do |n|
					(@stickies ||= []) << (@page.stickies.create Factory.next(:sticky) )
				end # 10 times
				xhr :get, :index, :page_id => @page.id
				@stickies_json = MultiJson.load response.body
			end # before each
			it "should have correct count" do
				@stickies_json.count.should == 10
			end # it
			["id", "user_id", "page_id", "content", "metadata", "category", "width", "height", "x", "y"].each do |field|
				it "should match #{field}" do
					@stickies_json.map { |s| s[field] }.each do |val|
						case field
						when "x","y"
							@stickies.map { |s| s[field.to_sym].to_f.to_s }.should include val
						else
							@stickies.map { |s| s[field.to_sym] }.should include val
						end # case filed
					end # each val
				end # it
			end # each field
		end # index
		describe "create" do
			before :each do
				@sticky_data = Factory.next :sticky
				@create = lambda { xhr :post, :create, :page_id => @page.id, :sticky => @sticky_data }
			end # before each
			it "should create" do
				@create.should change(Sticky, :count).by(1)
			end # it
			describe "details" do
				before :each do
					@create.call
					@sticky_json = MultiJson.load response.body
				end # before each			
				["content", "metadata", "category", "width", "height", "x", "y"].each do |field|
					it "should match expected #{field}" do
						case field
						when "x","y"
							@sticky_json[field].should == @sticky_data[field.to_sym].to_f.to_s
						else
							@sticky_json[field].should == @sticky_data[field.to_sym]
						end # case
					end # it
				end # each field
				it "should have a proper id" do
					@sticky_json["id"].should_not be_nil
				end # it
				it "should match user" do
					@sticky_json["user_id"].should be_nil
				end # it
				it "should match page" do
					@sticky_json["page_id"].should == @page.id
				end # it
			end # details
		end # create
	end # not-logged in
	describe "admin" do
		login_user
		before :each do
			@page = @current_user.pages.create Factory.next(:page)
			@sticky = @current_user.stickies.create Factory.next(:sticky)
			@sticky.page_id = @page.id
			@sticky.save!
		end # before each
		describe "update" do
			before :each do
				@sticky_data = Factory.next(:sticky)
				@update = lambda { xhr :put, :update, :page_id => @page.id, :id => @sticky.id, :sticky => @sticky_data }
			end # before each
			Sticky.attr_accessible[:default].each do |field|
				next if field.blank?
				it "should change the #{field} attribute" do
					key = field.to_sym
					@update.should change( lambda { Sticky.find(@sticky.id)[key] }, :call ).from(@sticky[key]).to(@sticky_data[key])
				end # it
			end # each field
		end # update
		describe "destroy" do
			before :each do
				@destroy = lambda { xhr :delete, :destroy, :page_id => @page.id, :id => @sticky.id }
			end # before each
			it "should destroy" do
				@destroy.should change(Sticky, :count).by(-1)
			end # it
			it "should kill the right one" do
				@destroy.call
				Sticky.where(@sticky.id).should be_empty
			end # it
		end # destroy
	end # admin
end # Stickies
