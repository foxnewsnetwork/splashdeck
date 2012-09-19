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
