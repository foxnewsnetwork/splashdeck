# The thing that gets loaded first
class DeskModel extends Backbone.Model
	@action_processor:
		comment: (input) ->
			data =
				content: input['content'] ,
				metadata: input['from'] ,
				category: "comment"
			# data
		, # comment
		image: (input) ->
			data =
				content: input['image'] ,
				metadata: input['caption'] ,
				category: "image"
			# data
		, # image
		text: (input) ->
			data =
				content: input['text'] ,
				metadata: input['style'] ,
				category: "text"
			# data
		, # text
		code: (input) ->
			data =
				content: input['code'] ,
				metadata: input['language'] ,
				category: "code"
			# data
		, # code
		login: (input) ->
			
		# login
	, # action_callbacks
	initialize: ->
		# Step 1: Initialize expected variables
		@toolbar = new ToolbarView()
		@active_page = new PageModel()
		@pages = [@active_page]
		@toolbar.render()
		@establish_connection()
		
		# Step 2: Register events
		Backbone.Events.on "modal:action", (input) ->
			data = DeskModel.action_processor[input['category']]( input )
			@active_page.new_sticky data
		# on modal:action
	, # initialize
	
	# Loads the latest page (if there is one) on initialization
	establish_connection: (callback) ->
		@active_page.fetch({
			url: "/" ,
			success: (model, response) ->
				if response? and response['id']?
					model.set response 
				else
					Flash.show( "WARNING: The owner of this blog hasn't written anything yet!" , "warning" )
				callback() if callback?
			, # success
			error: (response) ->
				Flash.show( "OH NO, WE GOT AN ERROR! #{JSON.stringify response}", "error" )
				callback(response) if callback?
			# error
		}) # fetch
	, # establish_connection
	
	goto_page: (number) ->
		if number < @pages.length
			@active_page.deactivate()
			@active_page = @pages[number]
			@active_page.activate()
		else
			Flash.show( "404: the page you requested #{number} doesn't exist", "warning" )
		# if-else
	, # goto_page
	
	new_page: (data, callback) ->
		page = new PageModel()
		page.set data, { "silent" : true }
		desk = this
		page.save( page, {
			success: (model, response) ->
				model.set response, { "silent" : true }
				desk.active_page = model
				desk.pages.push model
				Flash.show( "New Page Created! #{JSON.stringify response}", "success" )
				callback()
			, # success
			error: (response) ->
				Flash.show( "Dammit! New Page Creation Failed #{JSON.stringify response}", "error")
				callback()
			# error
		} ) # save
	, # new_page
# DeskModel
