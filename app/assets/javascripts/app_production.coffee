$.ajaxPrefilter (options, originalOptions, jqXHR) ->
	options.xhrFields = { 	"withCredentials": true }
	jqXHR.setRequestHeader( "X-CSRF-TOKEN", $("meta[name='csrf-token']").attr("content") )
# ajaxPrefilter

methodMap =
	'create': 'POST',
	'update': 'PUT',
	'delete': 'DELETE',
	'read':   'GET'
# methodMap

Backbone.sync = (method, model, options) ->
	type = methodMap[method]
		
	# Default options, unless specified.
	options or (options = {})

	# Default JSON-request options.
	params = {type: type, dataType: 'json'}

	# Ensure that we have a URL.
	if (!options.url)
		params.url = model.url or throw "URL ERROR #{JSON.stringify model}"

	# Ensure that we have the appropriate request data.
	if (!options.data and model and (method is 'create' or method is 'update'))
		params.contentType = 'application/json'
		temp_data = { "authenticity_token" : $("meta[name='csrf-token']").attr "content"	}
		throw "You Must Specifiy a Model Name Error #{JSON.stringify model}" unless model.name?
		temp_data[model.name] = model.serialize() if model.serialize?
		temp_data[model.name] = model.toJSON() unless model.serialize?
		params.data = JSON.stringify( temp_data )
    	
	# For older servers, emulate JSON by encoding the request into an HTML-form.
	if (Backbone.emulateJSON)
		params.contentType = 'application/x-www-form-urlencoded'
		params.data = if params.data then {model: params.data} else {}
	# if

	# For older servers, emulate HTTP by mimicking the HTTP method with `_method`
	# And an `X-HTTP-Method-Override` header.
	if (Backbone.emulateHTTP)
		if (type is 'PUT' or type is 'DELETE')
			if (Backbone.emulateJSON) 
				params.data._method = type
				params.type = 'POST'
				params.beforeSend = (xhr) ->
					xhr.setRequestHeader('X-HTTP-Method-Override', type)
					return
				# params.beforeSend
			# if 
		# if PUT or Delete
	# if HTTP

	# Don't process data on a non-GET request.
	params.processData = false if params.type isnt 'GET' and !Backbone.emulateJSON
		
	# Make the request, allowing the user to override any Ajax options.
	return $.ajax(_.extend(params, options))
# Backbone.sync


class Flash extends Backbone.View
	@container: ( ->
		$("body").append("<ul id='flash-container' class='flash-container'></ul>")
		return $("#flash-container")
	)() , # staticInitializer
	@show: (content, color) ->
		data = { 
			content: content ,
			color: if color then color else "info"
		} # data
		(new Flash()).render(data)
	, # static show
	tagName: "li" ,
	className: "alert alert-block" ,
	events: 
		"mouseover .alert": "diffusify" ,
		"mouseleave .alert": "focusify"
	, # events
	render: (data) ->
		$(@el).attr "class", "#{@className} alert-#{data['color']}" if data['color']?
		$(@el).html( data['content'] )
		Flash.container.append $(@el)
		setTimeout( ( (dom) -> 
			return ( -> 
				dom.$(dom.el).hide(1000)
				dom.remove() 
			) # return
		)(this), 5000 ) # setTimeout
		return this
	, # render
	diffusify: (e) ->
		$(@el).css "opacity", 0.5
	, # diffusify
	focusify: (e) ->
		$(@el).css "opacity", 1
	, # focusify
# Flash


# Singleton class for signing in
class Session extends Backbone.Model
	@admin : null ,
	@login : (email, password, callback) ->
		session = new Session({email : email, password : password})
		session.save( session, { 
			success : (model, response) ->
				if response['success']?
					Session.admin = session
					Backbone.Events.trigger "session:login"
					Flash.show( "Login Successful, Welcome Master", "success" )
					callback() if callback?
				else
					Flash.show("Login failed")
					callback("You have failed") if callback?
				# if-else
			, # success callback
			error : ->
				Flash.show("Wrong Email - Password Combination")
				callback("Wrong Email - Password Combination") if callback?
			# error
		} ) # session.save
	, # initialize
	@logout : (callback)->
		unless Session.admin?
			callback( "Not logged in")
			return 
		data = {}
		data['authenticity_token'] = $("meta[name='csrf-token']").attr( "content" )
		Session.admin = null
		Backbone.sync( "delete", Session.admin, { success : callback, url: "/users/sign_out" } )
	, # logout
	name: "user" ,
	url: "/users/sign_in" ,
# Session



class StickyModel extends Backbone.Model
	@debug_counter: 0 ,
	@attr_accessible: [ 
		'x','y','width','height','category','content','metadata'
	] , # attr_accessible
	name: "sticky" ,
	user_id: undefined ,
	page_id: undefined ,
	defaults :
		"x" : undefined ,
		"y" : undefined ,
		"width" : 300 ,
		"height" : 50 ,
		"category" : "text" ,
		"content" : undefined ,
		"metadata" : ""
	, # defaults
	serialize: ->
		data = {}
		for key in StickyModel.attr_accessible
			data[key] = @get key
		return data
	, # serialize
	initialize: ->
		StickyModel.debug_counter += 1
		unless @get("x")? and @get("y")?
			position = 
				x: 5 + 65 * Math.random() ,
				y: 5 + 65 * Math.random()
			# position
			@set( position, { silent: true } )
		if @get( "metadata" ) is ""
			switch @get "category"
				when "image"
					@set( { "metadata" : "No caption available" }, {silent: true} )
				when "code"
					@set( { "metadata" : "English" }, {silent: true} )
				when "comment"
					@set( { "metadata" : "anonymous" }, {silent: true} )
			# switch
		@setup_view()
	, # initialize
	setup_view: ->
		
		@view = new StickyView( model : this )
		@view.update_callback = (data) =>
			@save( data ) if @id?
		# update_callback
		@view.render()
	, # setup_view
	activate: ->
		@view.show()
	, # activate
	deactivate: ->
		@view.hide()
	, # deactivate
# StickyModel

class StickyView extends Backbone.View
	tagName: "div" ,
	className: "sticky-note ui-dialog ui-widget ui-widget-content ui-corner-all ui-draggable ui-resizable" ,
	template: 
		'comment' : _.template("<div class='resize-layer comment_block' style='display: inline-block;'>
			<button type='button' class='close' rel='tooltip' title='destroy'>&times;</button>
			<p class='comment_person'><%= metadata %></p>
			<p class='comment_content'><%= content %></p>
		</div>") , # comment template
		"text" : _.template("<div class='resize-layer' style='display: inline-block;'>
			<button type='button' class='close' rel='tooltip' title='destroy'>&times;</button>
			<p class='sticky_content' style='<%= metadata %>'><%= content %></p>
		</div>") , # text template
		"code" : _.template("<div class='resize-layer' style='display: inline-block;'>
			<button type='button' class='close' rel='tooltip' title='destroy'>&times;</button>
			<pre class='sticky_content prettyprint linenums' rel='tooltip' title='<%= metadata %>'>
				<code class='<%= metadata %>'><%= content %></code>
			</pre>	
		</div>") , # code template
		"image" : _.template("<div class='resize-layer' style='display: inline-block;'>
			<button type='button' class='close' rel='tooltip' title='destroy'>&times;</button>
			<img alt='some image' src='<%= content %>' class='sticky_content' rel='tooltip' title='<%= metadata %>'/>	
		</div>") # picture template
	, # templates
	events :
		"click .close" : "destroy"
	, # events
	parent: $( "body" ),
	update_callback: (data) ->
		throw "UPDATE CALLBACK NOT IMPLEMENTED YOU MORON ERROR"
	, # update_callback
	render: ->
		if !@model?
			throw "Calling View Without a Model Error"
			return this
		# if no model
		if !@ready?
			switch @model.get "category"
				when "text", "code", "image", "comment"
					$(@el).append( @template[@model.get "category"](@model.toJSON()) )
					$(@el).css "position", "absolute"
					$(@el).css "display", "inline-block"
					@parent.append( $(@el) );
					@ready = true
					this.$("[rel='tooltip']").tooltip()
					if @model.get( "category" ) == "code"
						hljs.highlightBlock( this.$("code").get()[0] )
					$(@el).resizable
						"alsoResize" : this.$(".sticky_content") ,
						"stop" : (e, ui) =>
							@update_callback @serialize()
							return false
						# stop
					# resizable
					$(@el).draggable 
						"stop" : (e, ui) =>
							@update_callback @serialize()
							return true
						# stop
					# draggable
				else
					throw "Unsupported sticky type error"
			# switch
		# if-else el
		for css_prop, js_prop of { "left" : "x", "top" : "y", "width" : "width", "height" : "height" }
			switch css_prop
				when "left","top"
					$(@el).css( css_prop, @model.toJSON()[js_prop] + "%")
				else
					$(@el).css( css_prop, @model.toJSON()[js_prop] )
			# switch
		# for
		return this
	, # render
	serialize: () ->
		{ 
			"x" : @el.offsetLeft / window.innerWidth  * 100,
			"y" : @el.offsetTop / window.innerHeight * 100 ,
			"width" : this.$(".sticky_content").css( "width" ),
			"height" : this.$(".sticky_content").css( "height" )
		}
	, # serializes only the positions (because content etc. isn't editable)
	destroy: (e) ->
		@remove()

		@model.destroy()
	, # destroy
	show: ->
		$(@el).show()
	, # show
	hide: ->
		$(@el).hide()
	, # hide
# StickView



class StickiesCollection extends Backbone.Collection
	model: StickyModel ,
	activate: ->
		@fetch({
			url: @url + "?offset=0&limit=50" ,
			success: (models, responses) =>
				for k in [1..models.length]
					model = models.at( k-1 )
					model.id = model.get "id"
					model.page_id = model.get "page_id"
					model.user_id = model.get "user_id"
					model.url = @url + "/#{model.id}"
				# for
				Flash.show( "Loaded #{responses.length} stickies from the server into #{JSON.stringify this}", "info")
			, # success
			error: (response) ->
				Flash.show( "Oh no, stickies collection fetch error #{JSON.stringify response}", "error" )
			, # error
		}) # fetch
	, # activate
	deactivate: ->
		_.each( this.toArray(), (sticky) -> 
			sticky.deactivate()
		) # forEach
	, # deactivate
# StickiesCollection



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


# Modal Form class
class ModalView extends Backbone.View
	@input_sanitizor: (string) ->
		# Escapes html by escaping brackets
		str = escape string
		# This has to be done in a while loop because javascript regex is fucking stupid
		while str.match /(%3C)|(%3E)/
			str = str.replace "%3C", "&lt;"
			str = str.replace "%3E", "&gt;"
		# while loop
		return unescape str
	, # input_sanitizor
	@modal_contents:
		comment: [
			{ name: "from", category: "text", placeholder: "You...", style: "input-medium" }
			{ name: "content", category: "text", placeholder: "My comment...", style: "input-large" }	 ,
		], # comment
		login: [ 
			{ name: "email", category: "text", placeholder: "Username or email...", style: "input-large" }	 ,
			{ name: "password", category: "password", placeholder: "", style: "input-large" }
		], # login
		code: [
			{ name: "code", category: "text", placeholder: "", style: "input-large" }	 ,
			{ name: "language", category: "text", placeholder: "e.g. Ruby", style: "input-small" }
		], # code
		text: [ 
			{ name: "text", category: "text", placeholder: "Some text...", style: "input-xlarge" }	 ,
			{ name: "style", category: "text", placeholder: "font-family: Arial;", style: "input-xlarge" }
		], # text
		image: [ 
			{ name: "image", category: "url", placeholder: "Link to your image...", style: "input-xlarge" }	,
			{ name: "caption", category: "text", placeholder: "Image caption", style: "input-xlarge" }	
		] , # image
		page: [ 
			{ name: "title", category: "text", placeholder: "Untitled...", style: "input-xlarge" } 
		] , # page
	, # modal_content
	@generate_form: (category) ->
		label = _.template "<label for='<%= name %>' class='control-label'><%= name %></label>"
		input = _.template "<input category='<%= category %>' placeholder='<%= placeholder %>' name='<%= name %>' class='<%= style %>' />"
		textarea = _.template "<textarea name='<%= name %>'></textarea>"
		output = "<fieldset><div class='control-group'>"
		things = ModalView.modal_contents[category]
		switch category
			when "page"
				output += "#{label things[0]} #{input things[0] }"
			when "comment"
				output += "#{label things[0]}#{input things[0]}" 	
				output += "#{label things[1]}#{textarea things[1]}" 
			when "login"
				for thing in things
					output += "#{label thing}#{input thing}" 
			when "code"
				output += "#{label things[0]}#{textarea things[0]}" 
				output += "#{label things[1]}#{input things[1]}" 	
			when "text"
				for thing in things
					output += "#{label thing}#{textarea thing}" 
			when "image"
				for thing in things
					output += "#{label thing}#{input thing}" 
			else
				throw "Not Support category ERROR #{category}"
		# switch
		output += "</fieldset></div>"
		return output
	, # generate_form
	@form:
		"comment" : { "modal_title" : "Leave Comment", "modal_body" : ModalView.generate_form("comment"), "modal_action" : "Comment" } ,
		"login" : { "modal_title" : "Owner Login", "modal_body" : ModalView.generate_form("login"), "modal_action" : "Login" } ,
		"text" : { "modal_title" : "Text Sticky", "modal_body" : ModalView.generate_form("text"), "modal_action" : "Write" } ,
		"image" : { "modal_title" : "Image Sticky", "modal_body" : ModalView.generate_form("image"), "modal_action" : "Link" } ,
		"code" : { "modal_title" : "Code Block", "modal_body" : ModalView.generate_form("code"), "modal_action" : "Post" } ,
		"page" : { "modal_title" : "New Page", "modal_body" : ModalView.generate_form("page"), "modal_action" : "Create" }
	, # @form
	tagName: "div" ,
	className: "modal hide fade" ,
	events: 
		"click .modal-action" : "modal_action"
	, # events
	template: _.template("
		<div class='modal-header'>
			<button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
			<h3 id='myModalLabel'><%= modal_title %></h3>
		</div>
		<div class='modal-body'>
			<%= modal_body %>
		</div>
		<div class='modal-footer'>
			<button class='btn' data-dismiss='modal' aria-hidden='true'>Close</button>
			<button class='btn btn-primary modal-action'><%= modal_action %></button>
		</div>
	") , # template
	modal_action: ->
		input = {}
		for set in ModalView.modal_contents[@category]
			name = set['name']
			input[name] = ModalView.input_sanitizor this.$("[name='#{name}']").val()
		# for
		$(@el).modal 'hide'
		input['category'] = @category		
		Backbone.Events.trigger "modal:action", input		
	, # modal_action
	render: (category)->
		# Step 1: Generate the forms
		switch category
			when "pages"
				$(@el).html("
					<div class='modal-header'>
						<button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
						<h3 id='myModalLabel'>Pages Index</h3>
					</div>
					<div class='modal-body'>
						<ul class='page-index'></ul>
					</div>")		
			else
				$(@el).html @template(ModalView.form[category])
		# switch
		@category = category
				
		# Step 2: Attach to the body
		$(@el).appendTo "body"
		
		# Step 3: Hide it
		$(@el).hide()

		# Step 4: Attach attributes
		# $(@el).attr "id", "#{category}-modal"
		for attr in [{ id: "#{category}-modal"}, { tabindex: -1}, { role: "dialog"}, {"aria-labelledby":"my#{category}label"}, {"aria-hidden":true}]
			for key, val of attr
				$(@el).attr key, val
			# key, val
		# attr
		
		# Step 5: GTFO	
		return "#{category}-modal"
	, # render
	generate_pages_index: (response) ->
		template = _.template("<li>
				<h4><a href='#<%= id %>' data-dismiss='modal' aria-hidden='true' class='close' content='<%= id %>'><%= title %></a></h4>
				<small><%= created_at %></small>
		</li>")
		this.$(".page-index").html("")
		for page in response
			this.$(".page-index").append( template(page) )
			this.$("a[href='##{page['id']}']").click( ((id) ->
				return ->
					Backbone.Events.trigger "modal:switch_page", id
				# return
			)(page['id']) )  # click
		# for
	# generate_pages_index
# ModalView


# Toolbar
class ToolbarView extends Backbone.View
	tagName: "ul" ,
	className: "desktop-toolbar ui-widget-content" ,
	mode: "normal" ,
	buttons: [
		{ "id" : "pages", "thing" : "Pages", "icon" : "book icon-white", "color" : "info" } ,
		{ "id" : "page", "thing" : "New Page", "icon" : "star icon-white", "color" : "success" } ,
		{ "id" : "login", "thing" : "Owner login", "icon" : "user icon-white", "color" : "inverse" } ,
		{ "id" : "comment", "thing" : "Leave comment", "icon" : "pencil icon-white", "color" : "primary" } ,
		{ "id" : "code", "thing" : "Code block", "icon" : "barcode", "color" : "default" } ,
		{ "id" : "image", "thing" : "Picture block", "icon" : "picture", "color" : "default" } ,
		{ "id" : "text", "thing" : "Text block", "icon" : "font", "color" : "default" }
	] , # buttons
	template: _.template("
		<li target='<%= id %>'><a href='#<%= id %>' id='btn-<%= id %>' class='btn btn-mini btn-<%= color %>' rel='tooltip' title='<%= thing %>' data-toggle='modal'>
			<i class='icon-<%= icon %>'></i>
		</li></a>
	") , # template
	events:
		"click #btn-pages": "pages_modal" ,
		"click #btn-comment" : "comment_modal" ,
		"click #btn-login" : "login_modal" ,
		"click #btn-page" : "page_modal" ,
		"click #btn-code" : "code_modal" ,
		"click #btn-image" : "image_modal" ,
		"click #btn-text" :"text_modal"
	, # events
	render:  ->
		if @ready?
			return
		# Step 1: Appending the template
		for button in @buttons
			$(@el).append @template(button)
			switch button["id"]
				when "comment", "login","code","image", "text", "page"
					modal = new ModalView()
					m_id = modal.render button['id']
					this.$("#btn-#{button['id']}").attr "data-target", "##{m_id}"
				# when
				when "pages"
					@pages_modal = new ModalView()
					m_id = @pages_modal.render "pages"
					this.$("#btn-pages").attr "data-target", "##{m_id}"
			# switch
		# for
			
		# Step 2: Appending the element
		$(@el).appendTo "body"
		$("a[rel='tooltip']").tooltip()
		$(@el).scrollspy()
		@ready = true
		
		# Step 3: Listen to events
		@unadminify()
		Backbone.Events.on( "session:login", @adminify )
		Backbone.Events.on( "desk:pages_fetch", (response) => 
			@pages_modal.generate_pages_index( response )
		) # desk:pages_fetch
	, # render
	
	adminify: =>
		@mode = "admin"
		for target in ['text','image','code','page'] 
			this.$("li[target='#{target}']").show()
		# for
	, # adminify
	
	unadminify: =>
		@mode = "normal"
		for target in ['text','image','code','page'] 
			this.$("li[target='#{target}']").hide()
		# for
	, # unadminify
	
	###
	# Modal Section
	###
	pages_modal: ->
		##
		# Note to future devs (probably just me... except in the future):
		# The event pathing goes as follows (we pobably should use callbacks)
		# toolbar:pages - caught by desk in intiailize function
		# desk:pages_fetch - caught by toolbar in render function
		# modal:switch_page - caught by desk in initialize function
		##
		Backbone.Events.trigger "toolbar:pages"
	, # pages_modal
	
	page_modal: ->
		if @mode is "admin"
			@open_modal( "page" )
		else
			Flash.show( "You need to be the owner of this blog in order to add new pages", "warning" )
		# if-else	
	, # page_modal
	
	login_modal: ->
		if @mode is "normal"
			@open_modal( "login" )
		else
			Flash.show( "You are already logged in!", "warning" )
		# if-else
	, # login_modal
	
	comment_modal: ->
		@open_modal( "comment" )
	, # comment_modal
	
	image_modal: ->
		@open_modal( "image" )
	, # image_modal
	
	text_modal: ->
		@open_modal( "text" )
	, # text_modal
	
	code_modal: ->
		@open_modal( "code" )
	, # code_modal
	
	open_modal: (category) ->
		$("#{category}-modal").modal()	
	, # open_modal
# Toolbar



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
			success: (model, response) =>
				if response? and response['id']?
					@active_page.set 'title', response['title']
					@active_page.id = response['id']
					@active_page.user_id = response['user_id']
					@active_page.url = "/pages/#{response['id']}"
					@active_page.stickies.url = model.url + "/stickies"
					@pages_hash[ response['id'] ] = @pages.length
					@pages.push @active_page
					@switch_to response['id']
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


desktop = null unless desktop?
$("document").ready ->
	$("div#no-javascript").hide()
	desktop = new DeskModel() unless desktop?
