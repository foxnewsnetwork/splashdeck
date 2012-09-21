
class StickiesCollection extends Backbone.Collection
	model: StickyModel ,
	activate: ->
		@fetch({
			url: @url + "?offset=0&limit=50" ,
			success: (model, responses) =>
				for response in responses
					sticky = new StickyModel( response )
					sticky.show()
					@push sticky
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
