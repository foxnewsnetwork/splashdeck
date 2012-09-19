require 'spec_helper'
require 'factories'
describe PagesController do
	describe "unused" do
		describe "GET 'legal'" do
			it "returns http success" do
			  get 'legal'
			  response.should be_success
			end
		end # legal

		describe "GET 'about'" do
			it "returns http success" do
			  get 'about'
			  response.should be_success
			end
		end # about
	end # unused
	describe "index" do
		before :each do
			@user = User.create :email => "asdfasdfa@fddf.com", :password => "jr2jlrkjaro0ijf0ij"
			10.times do
				(@pages ||= []) << @user.pages.create( Factory.next( :page ) )
			end # 10 times
			xhr :get, :index, :limit => 10, :offset => 0
			@data = MultiJson.load response.body
		end # before each
		["id", "title", "user_id"].each do |field|
			it "should match the #{field}" do
				@pages.map { |page| page[field.to_sym] }.each do |val|
					@data.map { |x| x[field] }.should include val
				end # each page
			end # it
		end # each field
		it "should have properly length" do
			@data.count.should == 10
		end # it
	end # index	
	describe "logged in" do
		login_user
		describe "create" do
			before :each do
				@page = { 
					:title => "Some title" 
				}# page
				@create = lambda { xhr :post, :create, :page => @page, :format => :json }
				
			end # before each
			it "should create a page" do
				@create.should change( Page, :count ).by(1)
			end # it
			describe "response" do
				before :each do
					@create.call
					@data = MultiJson.load response.body
				end # befor eaech
				it "should not be nil" do
					response.body.should_not be_blank
				end # it
				it "should have json" do
					@page.each do |key,  val|
						@data[key.to_s].should == val
					end # each key val
				end # it
				describe "update" do
					before :each do
						@new_page = { 
							:title => "Another title" 
						} # new_page
						@update = lambda { xhr :put, :update, :page => @new_page, :id => @data["id"], :format => :json }
					end # before :each
					it "should change title" do
						@update.should change( lambda { Page.find( @data["id"] )[:title] }, :call ).from( @page[:title] ).to( @new_page[:title] )
					end # it
				end # update
				describe "destroy" do
					before :each do
						@destroy = lambda { xhr :delete, :destroy, :id => @data["id"], :format => :json }
					end # before each
					it "should kill" do
						@destroy.should change( Page, :count ).by(-1)
					end # it
					it "should kill the right one" do
						@destroy.call
						Page.where( @data["id"] ).should be_empty
					end # it
				end # it
			end # response
		end # create
	end # logged in
end # Pages
