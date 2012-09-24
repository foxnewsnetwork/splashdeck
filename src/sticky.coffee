
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
				x: 0 ,
				y: 0
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
	className: "sticky-note" ,
	template: 
		'comment' : _.template("
			<p class='comment_person'><%= metadata %></p>
			<p class='comment_content'><%= content %></p>
		") , # comment template
		"text" : _.template("
			<p class='sticky_content' style='<%= metadata %>'><%= content %></p>
		") , # text template
		"code" : _.template("
			<pre class='sticky_content prettyprint linenums' rel='tooltip' title='<%= metadata %>'>
				<code class='<%= metadata %>'><%= content %></code>
			</pre>	
		") , # code template
		"image" : _.template("
			<img alt='some image' src='<%= content %>' class='sticky_content' rel='tooltip' title='<%= metadata %>'/>	
		") # picture template
	, # templates
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
			$(@el).append( @template[@model.get "category"](@model.toJSON()) )
			@parent.append( $(@el) );
			@ready = true
			this.$("[rel='tooltip']").tooltip()
			switch @model.get "category"
				when "code"
					hljs.highlightBlock( this.$("code").get()[0] )
					$(@el).attr "title", "Code"
				when "image"
					$(@el).attr "title", "Image"
				when "comment"
					$(@el).attr "title", "Comment"
				when "text"
					$(@el).attr "title", @model.get("metadata")
				else
					throw "Unsupported sticky type error"
			# switch
			$(@el).dialog(
				position: [@model.get("x") * window.innerWidth / 100 , @model.get("y") * window.innerHeight / 100] ,
				width: @model.get("width") ,
				height: @model.get("height") ,
				dragStop: (event, ui) =>
					@update_callback( { "x" : ui.position.left / window.innerWidth  * 100, "y" : ui.position.top / window.innerHeight * 100 } )
					return true
				, # dragStop
				resizeStop: (event, ui) =>
					@update_callback( { "width" : ui.size.width , "height" : ui.size.height } ) 
					return false
				, # resizeStop
				close: (event, ui) =>
					@destroy event
				# close
			) # dialog
		# if-else el
		return this
	, # render
	serialize: (event, ui) ->
		alert "WARNING: DEPRECATED FUNCTION SERIALIZE CALLED!"
		return { 
			"x" : ui.position.x / window.innerWidth * 100 ,
			"y" : ui.position.y / window.innerHeight * 100 ,
			"width" : $(@el).css( "width" ) ,
			"height" : $(@el).css( "height" )
		} # return
	, # serializes only the positions (because content etc. isn't editable)
	destroy: (e) ->
		@remove()
		@model.destroy()
		Flash.show "Got rid of that one (at least for now)!", "success"
	, # destroy
	show: ->
		$(@el).show()
	, # show
	hide: ->
		$(@el).hide()
	, # hide
# StickView
