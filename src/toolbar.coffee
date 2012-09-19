# Toolbar
class ToolbarView extends Backbone.View
	tagName: "ul" ,
	className: "desktop-toolbar ui-widget-content" ,
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
		<li><a href='#<%= id %>' id='btn-<%= id %>' class='btn btn-mini btn-<%= color %>' rel='tooltip' title='<%= thing %>' data-toggle='modal'>
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
	render: (action_callbacks) ->
		if @ready?
			return
		# Step 1: Appending the template
		for button in @buttons
			$(@el).append @template(button)
			switch button["id"]
				when "comment", "login","code","image", "text"
					modal = new ModalView()
					m_id = modal.render button['id'], action_callbacks[button['id']]
					this.$("#btn-#{button['id']}").attr "data-target", "##{m_id}"
				# when
			# switch
		# for
			
		# Step 2: Appending the element
		$(@el).appendTo "body"
		$("a[rel='tooltip']").tooltip()
		$(@el).scrollspy()
		@ready = true
	, # render
	
	pages_modal: ->
		
	, # pages_modal
	
	page_modal: ->
	
	, # page_modal
	
	login_modal: ->
		@open_modal( "login" )
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
	
	open_modal: (type) ->
		$("#{type}-modal").modal()	
	, # open_modal
# Toolbar

