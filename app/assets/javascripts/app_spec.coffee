
class StickyModel extends Backbone.Model
	defaults :
		"username" : "anonymous" ,
		"password" : undefined ,
		"paper_id" : undefined ,
		"x" : undefined ,
		"y" : undefined ,
		"width" : 300 ,
		"height" : 50 ,
		"type" : "text" ,
		"content" : undefined ,
		"metadata" : ""
	, # defaults
	urlRoot: "/sticky" ,
	initialize: ->
		for v in ['x','y']
			if !@get(v)?
				@set v, 5 + 65 * Math.random()
		if @get( "metadata" ) == ""
			switch @get "type"
				when "image"
					@set "metadata", "No caption available"
				when "code"
					@set "metadata", "English"
				when "comment"
					@set "metadata", "anonymous"
			# switch
		# if no data
		@on "change", =>
			@save()
		# on change
	, # initialize
# StickyModel

class StickyView extends Backbone.View
	tagName: "div" ,
	className: "sticky-note ui-widget-content" ,
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
	render: ->
		if !@model?
			throw "Calling View Without a Model Error"
			return this
		# if no model
		if !@ready?
			switch @model.get "type"
				when "text", "code", "image", "comment"
					$(@el).append( @template[@model.get "type"](@model.toJSON()) )
					$(@el).css "position", "absolute"
					$(@el).css "display", "inline-block"
					@parent.append( $(@el) );
					@ready = true
					this.$("[rel='tooltip']").tooltip()
					if @model.get( "type" ) == "code"
						hljs.highlightBlock( this.$("code").get()[0] )
					this.$(".resize-layer").resizable
						"alsoResize" : this.$(".sticky_content") ,
						"stop" : (e, ui) =>
							@model.set @serialize()
							return false
						# stop
					# resizable
					$(@el).draggable 
						"stop" : (e, ui) =>
							@model.set @serialize()
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
# StickView



class StickiesCollection extends Backbone.Collection
	model: StickyModel ,
	url: "/stickies" 
# StickiesCollection



class PaperModel extends Backbone.Model
	defaults:
		"date" : 0 ,
		"title" : "Untitled" ,
	, # defaults
	
	initialize: ->
		@stickies = new StickiesCollection()
	, # initialize
	
	new_sticky: (data) ->
		stick_data = $.extend( data, { "paper_id" : @id })
		@stickies.push( new StickyModel(stick_data) )
	, # new_sticky
	
# PaperModel


# Modal Form class
class ModalView extends Backbone.View
	@input_sanitizor: (string) ->
		alert string
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
			{ name: "from", type: "text", placeholder: "You...", style: "input-medium" }
			{ name: "content", type: "text", placeholder: "My comment...", style: "input-large" }	 ,
		], # comment
		login: [ 
			{ name: "username", type: "text", placeholder: "Username or email...", style: "input-large" }	 ,
			{ name: "password", type: "password", placeholder: "", style: "input-large" }
		], # login
		code: [
			{ name: "code", type: "text", placeholder: "", style: "input-large" }	 ,
			{ name: "language", type: "text", placeholder: "e.g. Ruby", style: "input-small" }
		], # code
		text: [ 
			{ name: "text", type: "text", placeholder: "Some text...", style: "input-xlarge" }	 ,
			{ name: "style", type: "text", placeholder: "font-family: Arial;", style: "input-xlarge" }
		], # text
		image: [ 
			{ name: "image", type: "url", placeholder: "Link to your image...", style: "input-xlarge" }	,
			{ name: "caption", type: "text", placeholder: "Image caption", style: "input-xlarge" }	
		] , # image
	, # modal_content
	@generate_form: (type) ->
		label = _.template "<label for='<%= name %>' class='control-label'><%= name %></label>"
		input = _.template "<input type='<%= type %>' placeholder='<%= placeholder %>' name='<%= name %>' class='<%= style %>' />"
		textarea = _.template "<textarea name='<%= name %>'></textarea>"
		output = "<fieldset><div class='control-group'>"
		things = ModalView.modal_contents[type]
		switch type
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
				throw "Not Support Type ERROR #{type}"
		# switch
		output += "</fieldset></div>"
		return output
	, # generate_form
	@form:
		"comment" : { "modal_title" : "Leave Comment", "modal_body" : ModalView.generate_form("comment"), "modal_action" : "Comment" } ,
		"login" : { "modal_title" : "Owner Login", "modal_body" : ModalView.generate_form("login"), "modal_action" : "Login" } ,
		"text" : { "modal_title" : "Text Sticky", "modal_body" : ModalView.generate_form("text"), "modal_action" : "Write" } ,
		"image" : { "modal_title" : "Image Sticky", "modal_body" : ModalView.generate_form("image"), "modal_action" : "Link" } ,
		"code" : { "modal_title" : "Code Block", "modal_body" : ModalView.generate_form("code"), "modal_action" : "Post" }
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
		for set in ModalView.modal_contents[@type]
			name = set['name']
			input[name] = ModalView.input_sanitizor this.$("[name='#{name}']").val()
		# for
		
		$(@el).modal 'hide'
		
		if !@action_callback?
			throw "No Action Callback Error #{@type}, No Idea what submission of #{JSON.stringify input} is suppose to do"
		# if no callback
		
		@action_callback input
	, # modal_action
	render: (type, @action_callback)->
		# Step 1: Generate the forms
		$(@el).html @template(ModalView.form[type])
		@type = type
				
		# Step 2: Attach to the body
		$(@el).appendTo "body"
		
		# Step 3: Hide it
		$(@el).hide()

		# Step 4: Attach attributes
		# $(@el).attr "id", "#{type}-modal"
		for attr in [{ id: "#{type}-modal"}, { tabindex: -1}, { role: "dialog"}, {"aria-labelledby":"my#{type}label"}, {"aria-hidden":true}]
			for key, val of attr
				$(@el).attr key, val
			# key, val
		# attr
		
		# Step 5: GTFO	
		return "#{type}-modal"
	, # render
# ModalView


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



# The thing that gets loaded first
class DeskModel extends Backbone.Model
	@action_callbacks:
		comment: (input) ->
			data =
				content: input['content'] ,
				metadata: input['from'] ,
				type: "comment"
			# data
			sticky = new StickyModel data 
			
			# The following should be in the save callback
			view = new StickyView({model: sticky})
			view.render()
		, # comment
		image: (input) ->
			data =
				content: input['image'] ,
				metadata: input['caption'] ,
				type: "image"
			# data
			sticky = new StickyModel data 
			
			# The following should be in the save callback
			view = new StickyView({model: sticky})
			view.render()
		, # image
		text: (input) ->
			data =
				content: input['text'] ,
				metadata: input['style'] ,
				type: "text"
			# data
			sticky = new StickyModel data 
			
			# The following should be in the save callback
			view = new StickyView({model: sticky})
			view.render()
		, # text
		code: (input) ->
			data =
				content: input['code'] ,
				metadata: input['language'] ,
				type: "code"
			# data
			sticky = new StickyModel data 
			
			# The following should be in the save callback
			view = new StickyView({model: sticky})
			view.render()
		, # code
		login: (input) ->
			
		# login
	, # action_callbacks
	initialize: ->
		@toolbar = new ToolbarView()
		@active_paper = new PaperModel()
		@toolbar.render DeskModel.action_callbacks 
	# initialize
# DeskModel


# Globals (I guess)
desktop = new DeskModel()

describe "Desk Model", ->
	describe "sanity test", ->
		it "should not be null", ->
			expect(desktop).to.be.ok()
		# it
	# sanity test
# Desk Model
