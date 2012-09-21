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
			data =
				email: input['email'] ,
				password: input['password'] ,
				category: 'login'
		, # login
		page: (input) ->
			data =
				title: input['title']
		, # page
	, # action_callbacks
	initialize: ->
		# Step 1: Initialize expected variables
		@toolbar = new ToolbarView()
		@active_page = new PageModel()
		@pages = []
		@pages_hash = {}
		@toolbar.render()
		@establish_connection()
		
		# Step 2: Register events
		Backbone.Events.on "modal:action", (input) =>
			data = DeskModel.action_processor[input['category']]( input )
			switch input['category']
				when 'page'
					@new_page( data )
				when 'login'
					Session.login( input['email'], input['password'] )
				else
					@active_page.new_sticky data	
			# switch
		# on modal:action
		Backbone.Events.on "toolbar:pages", =>
			@fetch( { 
				url: "/pages?offset=0&limit=50" ,
				success: (model, response) ->
					if response?
						Backbone.Events.trigger "desk:pages_fetch", response
					else
						Flash.show( "Oh no, we ran into a problem trying to load pages index", "error")
				, # success
				error: (response) ->
					Flash.show( "Oh no, we ran into a problem trying to load pages index #{JSON.stringify response}", "error")
				, # error
			} ); # fetch
		# on toolbar:pages
		Backbone.Events.on "modal:switch_page", (id) =>
			@switch_to(id)
		# on switch_page
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
	
	switch_to: (id) ->
		if @pages_hash[id]?
			@goto_page( @pages_hash[id] )
		else
			page = new PageModel()
			page.id = id
			page.url = "/pages/#{id}"
			page.stickies.url = "/pages/#{id}/stickies"
			page.fetch({
				success: (model, response) =>
					page.set "title", response['title']
					@pages_hash[id] = @pages.length
					@pages.push page
					@switch_to( id )
				, # success
				error: (response) ->
					Flash.show( "The ID #{id} you requested isn't cached on your local machine and isn't in the db.", "error" )
				# error
			}) # fetch
	, # switch_to
	
	goto_page: (number) ->
		if !number? or number < @pages.length 
			@active_page.deactivate()
			@active_page = @pages[number] if number?
			@active_page = @pages[@pages.length - 1] unless number?
			@active_page.activate()
			Flash.show( "We have switched to page #{@active_page.get 'title'}", "info" )
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
				model.id = response['id']
				model.user_id = response['user_id']
				model.stickies.url = "/pages/#{response['id']}/stickies"
				desk.pages_hash[response['id']] = desk.pages.length
				desk.pages.push model
				desk.goto_page()
				Flash.show( "New Page Created! #{JSON.stringify response}", "success" )
				callback() if callback?
			, # success
			error: (response) ->
				Flash.show( "Dammit! New Page Creation Failed #{JSON.stringify response}", "error")
				callback() if callback?
			# error
		} ) # save
	, # new_page
# DeskModel
