
class StickiesCollection extends Backbone.Collection
	model: StickyModel ,
	activate: ->
		@fetch({
			url: @url + "?offset=0&limit=50" ,
			success: (models, responses) =>
				for k in [1..models.length]
					model = models.at( k-1 )
					model.id = model.get "id"
					model.page_id = model.get "page_id"
					model.user_id = model.get "user_id"
					model.url = @url + "/#{model.id}"
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
