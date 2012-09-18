class PagesController < ApplicationController
	before_filter :filter_anonymous_user, :only => [:create, :update, :destroy]
	
	def legal
	end

	def about
	end

	def show
		@page = Page.find params[:id]
		respond_to { |f| f.json }
	end # show

	def index
		@pages = Page.limit( params[:limit].to_i ).offset( params[:offset].to_i )
		respond_to { |f| f.json }
	end # show

	def create
		@page = current_user.create params[:page]
		render_or_fail @page
	end # create

	def update
		@page = Page.find( params[:id] )
		render_or_fail @page.update_attributes params[:page]
	end # update

	def destroy
		@page = Page.find params[:id]
		render_or_fail @page.destroy
	end # destroy
	
	private
		def render_or_fail( condition = false )
			if condition
				respond_to { |f| f.json { render "pages/show" } }
			else
				respond_to { |f| f.json { render "shared/fail" } }
			end # if update
		end # render_or_fail
end # pages
