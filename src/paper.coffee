
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
