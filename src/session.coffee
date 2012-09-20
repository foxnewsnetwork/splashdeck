# Singleton class for signing in
class Session extends Backbone.Model
	@admin : null ,
	@login : (email, password, callback) ->
		session = new Session({email : email, password : password})
		session.save( session, { 
			success : (model, response) ->
				if response['success']?
					Session.admin = session
					Backbone.Events.trigger "session:login"
					Flash.show( "Login Successful, Welcome Master", "success" )
					callback() if callback?
				else
					Flash.show("Login failed")
					callback("You have failed") if callback?
				# if-else
			, # success callback
			error : ->
				Flash.show("Wrong Email - Password Combination")
				callback("Wrong Email - Password Combination") if callback?
			# error
		} ) # session.save
	, # initialize
	@logout : (callback)->
		unless Session.admin?
			callback( "Not logged in")
			return 
		data = {}
		data['authenticity_token'] = $("meta[name='csrf-token']").attr( "content" )
		Session.admin = null
		Backbone.sync( "delete", Session.admin, { success : callback, url: "/users/sign_out" } )
	, # logout
	name: "user" ,
	url: "/users/sign_in" ,
# Session
