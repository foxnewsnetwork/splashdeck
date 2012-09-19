class StickiesController < ApplicationController
	before_filter :filter_anonymous_user, :only => [:destroy]
	
	def show
		@sticky = Sticky.find_by_id params[:id]
		render_or_fail @sticky
	end # show
	
	def index
		@page = Page.find_by_id params[:page_id]
		@stickies = @page.stickies
		respond_to do |f|
			f.json { render :json => @stickies }
		end # respond_to
	end # index
	
	def create
		@page = Page.find_by_id params[:page_id]
		unless @page.nil?
			if user_signed_in?
				@sticky = current_user.stickies.new params[:sticky]
				@sticky.page_id = @page.id
				@sticky.save!
			else
				@sticky = @page.stickies.create params[:sticky]
			end # if signed_in
		end # no page		
		render_or_fail @sticky
	end # create
	
	def update
		@sticky = Sticky.find params[:id]
		if user_signed_in?
			render_or_fail @sticky.update_attributes( params[:sticky] )
		else
			if @sticky.user_id.nil?
				render_or_fail @sticky.update_attributes( params[:sticky] ) 
			else
				render_or_fail false
			end # if free sticky
		end # if signed in
	end # update
	
	def destroy
		@sticky = Sticky.find params[:id]
		render_or_fail @sticky.destroy
	end # destroy
	
	private
		def render_or_fail condition
			if condition
				respond_to { |f| f.json { render :json => @sticky } }
			else
				respond_to { |f| f.json { render "shared/fail" } }
			end # if condition
		end # render_or_fail
end # Stickies
