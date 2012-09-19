class PagesController < ApplicationController
	before_filter :filter_anonymous_user, :only => [:create, :update, :destroy]
	
	def legal
	end

	def about
	end

	def home
		respond_to do |format|
			format.html
			format.json do
				render :json => Page.last
			end # json
		end # respond_to
	end # home
	
	def show
		@page = Page.find params[:id]
		respond_to { |f| f.json }
	end # show

	def index
		@pages = Page.limit( params[:limit].to_i ).offset( params[:offset].to_i )
		respond_to { |f| f.json { render :json => @pages } }
	end # show

	def create
		@page = current_user.pages.create! params[:page]
		Page.attr_accessible[:default].each do |key|
			next if key.blank?
			raise "#{key} => #{@page[key.to_sym]} error" if @page[key.to_sym].nil? || @page[key.to_sym].blank?
		end # each key
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
				respond_to { |f| f.json { render :json => @page } }
			else
				respond_to { |f| f.json { render "shared/fail" } }
			end # if update
		end # render_or_fail
end # pages
