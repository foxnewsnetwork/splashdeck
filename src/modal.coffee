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
