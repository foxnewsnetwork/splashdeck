
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
