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

