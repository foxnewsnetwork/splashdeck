# Singleton class for signing in
class Session extends Backbone.Model
	@admin : null ,
	@login : (username, password) ->
		session = new Session()
		session.save( { username: username, password: password }, { 
			success : (model, response) ->
				if response['success']?
					Session.admin = session
					Session.adminify()
				else
					Flash.show("Login failed")
				# if-else
			, # success callback
			error : ->
				Flash.show("Couldn't connect to server, sorry")
			# error
		} ) # session.save
	, # initialize
# Session
