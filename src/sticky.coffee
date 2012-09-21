
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
