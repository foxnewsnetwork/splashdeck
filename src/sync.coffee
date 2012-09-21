$.ajaxPrefilter (options, originalOptions, jqXHR) ->
	options.xhrFields = { 	"withCredentials": true }
	jqXHR.setRequestHeader( "X-CSRF-TOKEN", $("meta[name='csrf-token']").attr("content") )
# ajaxPrefilter

methodMap =
	'create': 'POST',
	'update': 'PUT',
	'delete': 'DELETE',
	'read':   'GET'
# methodMap

Backbone.sync = (method, model, options) ->
	type = methodMap[method]
		
	# Default options, unless specified.
	options or (options = {})

	# Default JSON-request options.
	params = {type: type, dataType: 'json'}

	# Ensure that we have a URL.
	if (!options.url)
		params.url = model.url or throw "URL ERROR #{JSON.stringify model}"

	# Ensure that we have the appropriate request data.
	if (!options.data and model and (method is 'create' or method is 'update'))
		params.contentType = 'application/json'
		temp_data = { "authenticity_token" : $("meta[name='csrf-token']").attr "content"	}
		throw "You Must Specifiy a Model Name Error #{JSON.stringify model}" unless model.name?
		temp_data[model.name] = model.serialize() if model.serialize?
		temp_data[model.name] = model.toJSON() unless model.serialize?
		params.data = JSON.stringify( temp_data )
    	
	# For older servers, emulate JSON by encoding the request into an HTML-form.
	if (Backbone.emulateJSON)
		params.contentType = 'application/x-www-form-urlencoded'
		params.data = if params.data then {model: params.data} else {}
	# if

	# For older servers, emulate HTTP by mimicking the HTTP method with `_method`
	# And an `X-HTTP-Method-Override` header.
	if (Backbone.emulateHTTP)
		if (type is 'PUT' or type is 'DELETE')
			if (Backbone.emulateJSON) 
				params.data._method = type
				params.type = 'POST'
				params.beforeSend = (xhr) ->
					xhr.setRequestHeader('X-HTTP-Method-Override', type)
					return
				# params.beforeSend
			# if 
		# if PUT or Delete
	# if HTTP

	# Don't process data on a non-GET request.
	params.processData = false if params.type isnt 'GET' and !Backbone.emulateJSON
		
	# Make the request, allowing the user to override any Ajax options.
	return $.ajax(_.extend(params, options))
# Backbone.sync
