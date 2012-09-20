
class StickiesCollection extends Backbone.Collection
	model: StickyModel ,
	activate: ->
		@fetch({
			url: @url + "?offset=0&limit=50" ,
			success: (model, responses) ->
				for response in responses
					sticky = new StickyModel( response )
					sticky.show()
					model.push sticky
				# for
				Flash.show( "Loaded #{responses.length} stickies from the server", "info")
			, # success
			error: (response) ->
				Flash.show( "Oh no, #{JSON.stringify response}", "error" )
			, # error
		}) # fetch
	, # activate
	deactivate: ->
		for sticky in this
			sticky.hide()
		@reset()
	, # deactivate
# StickiesCollection
