
class PageModel extends Backbone.Model
	defaults:
		"title" : "Untitled" ,
	, # defaults
	url: "/pages" ,
	name: "page" ,
	initialize: ->
		@stickies = new StickiesCollection()
	, # initialize
	
	new_sticky: (data, callback) ->
		sticky = new StickyModel(data)
		sticky.url = "/pages/#{@id}/stickies"
		sticky.save( sticky.serialize(), { 
			success: (model, response) =>
				if response? and response['id']?
					sticky.id = response['id']
					sticky.user_id = response['user_id']
					sticky.page_id = response['page_id']
					sticky.url += "/#{response['id']}"
					@stickies.push( sticky )			
					Flash.show( "New sticky created #{JSON.stringify model}", "success" )
				else
					Flash.show( "Something went wrong with saving...", "error" )
				callback(response) if callback?
			, # success
			error: (response) ->
				Flash.show( "You have failed to create the sticky #{JSON.stringify response}", "error" )
				callback(response) if callback?
			, # error
		} ) # save
		return sticky
	, # new_sticky

	activate: ->
		$("title").html this.get("title")
		@stickies.activate()
		
		Backbone.Events.trigger "page:activate", this.id
	, # activate	
	
	deactivate: ->
		@stickies.deactivate()
		Backbone.Events.trigger "page:deactivate", this.id
	, # deactivate
# PaperModel
