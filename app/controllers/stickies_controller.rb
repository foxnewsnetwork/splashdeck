class StickiesController < ApplicationController
	before_filter :filter_anonymous_users, :only => [:destroy]
	
	def show
		@sticky = Sticky.find_by_id params[:id]
		render_or_fail @sticky
	end # show
	
	def index
		@page = Page.find_by_id params[:page_id]
		@stickies = @page.stickies
		respond_to do |f|
			f.json
		end # respond_to
	end # index
	
	def create
		@page = Page.find_by_id params[:page_id]
		if user_signed_in?
			@sticky = current_user.stickies.create params[:sticky].merge(:page_id => @page.id)
		else
			@sticky = @page.stickies.create params[:sticky]
		end # if signed_in		
		render_or_fail @sticky
	end # create
	
	def update
		@sticky = Sticky.find params[:id]
		if user_signed_in?
			render_or_fail @sticky.update_attributes( params[:sticky] )
		else
			render_or_fail @sticky.update_attributes( params[:sticky] ) if @sticky.user_id.nil?
		end # if signed in
	end # update
	
	def destroy
		@sticky = Sticky.find params[:id]
		render_or_fail @sticky.destroy
	end # destroy
	
	private
		def render_or_fail condition
			if condition
				respond_to { |f| f.json { render "stickies/show" } }
			else
				respond_to { |f| f.json { render "shared/fail" } }
			end # if condition
		end # render_or_fail
end # Stickies
