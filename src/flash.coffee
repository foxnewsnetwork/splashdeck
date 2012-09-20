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
